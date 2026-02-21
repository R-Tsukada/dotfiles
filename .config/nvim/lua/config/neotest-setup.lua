-- neotest関連設定（完全Lua版）
local ok, err = pcall(function()
  local map = vim.keymap.set

  -- neotest設定（Playwright結果不一致 調査用デバッグ拡張）
  local playwright_quiet = true

  -- neotest-playwright はデフォルトで vim.loop.cwd() を Playwright プロジェクト root として扱う。
  -- nvim をプロジェクト外で起動してると playwright.config.* / node_modules を見失って
  -- discovery が空になり「No tests found」になりがち。
  -- いま開いてるバッファのパスから playwright.config.* を祖先探索して root を推定する。
  local function playwright_root_for_path(file_path)
    local buf = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(buf)
    local target = file_path
    if not target or target == '' then
      target = bufname
    end
    if not target or target == '' then
      return vim.loop.cwd()
    end

    local ok_discover, discover = pcall(require, 'neotest-playwright.discover')
    if not ok_discover or type(discover.root) ~= 'function' then
      return vim.loop.cwd()
    end

    local root = discover.root(target)
    return root or vim.loop.cwd()
  end

  local function playwright_root_from_current_buffer()
    return playwright_root_for_path(nil)
  end

  -- neotest-playwright の discover_positions は内部で neotest.lib.treesitter.parse_positions
  -- (async) を呼ぶので、同期コンテキストから呼ばれると落ちることがある。
  -- ただし nio.run() は Task を返してしまうため、そのまま返すと neotest 側が壊れる。
  -- → 非async時だけ callback 完了まで vim.wait で同期的に待つ。
  local function patch_playwright_adapter_async(adapter)
    local ok_nio, nio = pcall(require, "nio")
    if not ok_nio or not adapter or type(adapter.discover_positions) ~= "function" then
      return adapter
    end

    -- Neovim(LuaJIT=Lua5.1) だと table.unpack が無いことがある
    local t_unpack = table.unpack or unpack

    local function await_in_any_context(fn)
      if type(nio.current_task) == 'function' and nio.current_task() then
        return fn()
      end

      local done = false
      local ok = false
      local result = nil
      local err = nil

      nio.run(fn, function(success, ...)
        ok = success
        if success then
          result = { ... }
        else
          err = { ... }
        end
        done = true
      end)

      local waited = vim.wait(30000, function()
        return done
      end, 10)

      if not waited then
        error('neotest-playwright: async timeout')
      end
      if not ok then
        error(tostring(err and err[1] or 'unknown error'))
      end
      return t_unpack(result or {})
    end

    if adapter._patched_async then
      return adapter
    end

    local function with_cwd(temp_cwd, fn)
      local prev = vim.loop.cwd()
      if temp_cwd and temp_cwd ~= '' and prev ~= temp_cwd then
        pcall(vim.loop.chdir, temp_cwd)
      end

      local ok_call, result = pcall(fn)

      if prev and prev ~= '' and vim.loop.cwd() ~= prev then
        pcall(vim.loop.chdir, prev)
      end

      if not ok_call then
        error(result)
      end
      return result
    end

    local orig_discover = adapter.discover_positions
    adapter.discover_positions = function(...)
      local args = { ... }
      local cwd = playwright_root_for_path(type(args[1]) == 'string' and args[1] or nil)
      return await_in_any_context(function()
        return with_cwd(cwd, function()
          return orig_discover(t_unpack(args))
        end)
      end)
    end

    if type(adapter.build_spec) == 'function' then
      local orig_build_spec = adapter.build_spec
      adapter.build_spec = function(...)
        local args = { ... }
        local cwd = playwright_root_from_current_buffer()
        do
          local ok_tree = type(args[1]) == 'table' and args[1].tree and type(args[1].tree.data) == 'function'
          if ok_tree then
            local pos = args[1].tree:data()
            if pos and pos.path then
              cwd = playwright_root_for_path(pos.path)
            end
          end
        end
        return with_cwd(cwd, function()
          return orig_build_spec(t_unpack(args))
        end)
      end
    end

    adapter._patched_async = true
    return adapter
  end

  local function neotest_playwright_adapter()
    -- Playwright の `--list` は JSON を返す想定やけど、プロジェクト側の dotenv 初期化が
    -- stdout にログを吐くと JSON が汚れて vim.fn.json_decode が落ちる。
    -- それが原因で discover_positions まで失敗して「No tests found」になるので、
    -- JSON 部分だけを抜き出して decode するようにパッチを当てる。
    pcall(function()
      -- IMPORTANT: neotest-playwright は populate_data を subprocess で実行することがある。
      -- 子プロセスだとこのパッチが効かず、dotenv の stdout ログで JSON decode が死ぬ。
      -- ここでは subprocess を無効化して、親プロセスで確実に処理させる。
      local lib = require('neotest.lib')
      if lib and lib.subprocess and type(lib.subprocess.enabled) == 'function' then
        lib.subprocess.enabled = function()
          return false
        end
      end

      local pw = require('neotest-playwright.playwright')
      local buildCommand = require('neotest-playwright.build-command').buildCommand
      local options = require('neotest-playwright.adapter-options').options
      local logger = require('neotest-playwright.logging').logger

      local function extract_json_payload(output)
        if type(output) ~= 'string' then
          return nil
        end
        local start_idx = output:find('{', 1, true)
        if not start_idx then
          return nil
        end
        -- `.*()}` は Lua パターン的にやや扱いづらいので最後の `}` を探す
        local last_brace = nil
        do
          local i = #output
          while i > 0 do
            if output:sub(i, i) == '}' then
              last_brace = i
              break
            end
            i = i - 1
          end
        end
        if not last_brace or last_brace <= start_idx then
          return nil
        end
        return output:sub(start_idx, last_brace)
      end

      local function run_command(cmd)
        local handle = io.popen(cmd)
        if not handle then
          return nil
        end
        local out = handle:read('*a')
        handle:close()
        return out
      end

      pw.get_config = function()
        local cmd_tbl = buildCommand(
          {
            bin = options.get_playwright_binary(),
            config = options.get_playwright_config(),
            reporters = { 'json' },
          },
          { '--list' }
        )

        local env_parts = {}
        for k, v in pairs(options.env or {}) do
          env_parts[#env_parts + 1] = tostring(k) .. '=' .. tostring(v)
        end
        if #env_parts > 0 then
          table.insert(cmd_tbl, 1, table.concat(env_parts, ' '))
        end

        local cmd = table.concat(cmd_tbl, ' ')
        local output = run_command(cmd)
        if type(output) ~= 'string' or output == '' then
          error('Failed to get Playwright config: no output')
        end

        local ok_dec, decoded = pcall(vim.fn.json_decode, output)
        if ok_dec then
          return decoded
        end

        local payload = extract_json_payload(output)
        if payload then
          local ok2, decoded2 = pcall(vim.fn.json_decode, payload)
          if ok2 then
            logger('debug', 'Patched get_config(): extracted JSON payload from noisy stdout')
            return decoded2
          end
        end

        error('Failed to decode Playwright --list JSON (stdout contained non-JSON output)')
      end
    end)

    local adapter = require('neotest-playwright').adapter({
      options = {
        persist_project_selection = true,
        enable_dynamic_test_discovery = true,
        get_cwd = playwright_root_from_current_buffer,
        extra_args = playwright_quiet and { '--quiet' } or {},
        env = {
          DOTENV_CONFIG_QUIET = playwright_quiet and 'true' or 'false',
        },
      },
    })

    return patch_playwright_adapter_async(adapter)
  end

  -- treesitter設定を先に実行（重要！）
  require('nvim-treesitter.config').setup {
    ensure_installed = {
      "typescript",
      "tsx",
    },
    highlight = {
      enable = true,
      disable = { "help" },
    },
    auto_install = false,
  }

  require('neotest').setup({
    adapters = { neotest_playwright_adapter() },
    log_level = vim.log.levels.INFO,
    consumers = {
      playwright = require('neotest-playwright.consumers').consumers,
    },
  })

  local map = vim.keymap.set
vim.api.nvim_create_user_command('NeotestLogPath', function()
  local ok, logging = pcall(require, 'neotest.logging')
  if not ok or not logging then
    print('neotest logging 未初期化')
    return
  end

  local path = nil
  if type(logging.get_filename) == 'function' then
    path = logging:get_filename()
  end
  if not path or path == '' then
    print('neotest logging 未初期化')
    return
  end

  print('neotest log: ' .. path)
end, {})

-- Playwright quiet トグル (再setup) :NeotestPlaywrightToggleQuiet
vim.api.nvim_create_user_command('NeotestPlaywrightToggleQuiet', function()
  playwright_quiet = not playwright_quiet
  require('neotest').setup({
    adapters = { neotest_playwright_adapter() },
    log_level = require('neotest').config.log_level,
  })
end, {})

-- カーソル位置のテストをUIモードで実行する関数
local function run_nearest_test_ui()
  local file_path = vim.fn.expand('%:p')
  local current_line = vim.fn.getline('.')
  
  -- カーソル行からテスト名を抽出
  local test_name = string.match(current_line, "test%s*%(%s*['\"]([^'\"]+)['\"]")
  if not test_name then
    test_name = string.match(current_line, "describe%s*%(%s*['\"]([^'\"]+)['\"]")
  end
  
  if test_name then
    local command = string.format('npx playwright test %s --ui --grep "%s"', 
                                  vim.fn.shellescape(file_path), 
                                  vim.fn.shellescape(test_name))
    print('実行中: ' .. command)
    vim.cmd('T ' .. command)
  else
    local command = string.format('npx playwright test %s --ui', vim.fn.shellescape(file_path))
    print('実行中: ' .. command)
    vim.cmd('T ' .. command)
  end
end

vim.api.nvim_create_user_command('NeotestRunNearestUI', run_nearest_test_ui, {})

-- キーマッピング設定
map('n', '<leader>tt', '<Cmd>lua require("neotest").run.run()<CR>', { desc = 'Run nearest test' })
map('n', '<leader>tf', '<Cmd>lua require("neotest").run.run(vim.fn.expand("%:p"))<CR>', { desc = 'Run current file tests' })
map('n', '<leader>td', '<Cmd>lua require("neotest").run.run({strategy = "dap"})<CR>', { desc = 'Debug nearest test' })
map('n', '<leader>ts', '<Cmd>lua require("neotest").summary.toggle()<CR>', { desc = 'Toggle test summary' })
map('n', '<leader>to', '<Cmd>lua require("neotest").output.open({enter = true})<CR>', { desc = 'Open test output' })
map('n', '<leader>ttu', '<Cmd>NeotestRunNearestUI<CR>', { desc = 'Run nearest test in UI mode' })
map('n', '<leader>tp', '<Cmd>NeotestPlaywrightProject<CR>', { desc = 'Playwright project settings' })
map('n', '<leader>tpr', '<Cmd>NeotestPlaywrightPreset<CR>', { desc = 'Playwright preset' })
map('n', '<leader>tra', '<Cmd>NeotestPlaywrightRefresh<CR>', { desc = 'Playwright refresh' })
map('n', '<leader>ta', '<Cmd>lua require("neotest").playwright.attachment()<CR>', { desc = 'Show playwright attachments' })
map('n', '<leader>th', '<Cmd>NeotestPlaywrightPreset<CR>', { desc = 'Set headed preset' })
map('n', '<leader>tdb', '<Cmd>NeotestPlaywrightPreset<CR>', { desc = 'Debug mode test' })
map('n', '<leader>tw', '<Cmd>lua require("neotest").watch.toggle()<CR>', { desc = 'Toggle watch mode (nearest)' })

end)

if not ok then
  vim.notify("Neotest setup failed: " .. tostring(err), vim.log.levels.ERROR)
end
