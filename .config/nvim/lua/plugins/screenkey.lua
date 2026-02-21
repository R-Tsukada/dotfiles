return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "thenbe/neotest-playwright",
    },
    event = "VeryLazy",
    config = function()
      local map = vim.keymap.set
      
      -- neotest設定（Playwright結果不一致 調査用デバッグ拡張）
      local playwright_quiet = true

      local function neotest_playwright_adapter()
        return require('neotest-playwright').adapter({
          options = {
            persist_project_selection = true,
            enable_dynamic_test_discovery = true,
            extra_args = playwright_quiet and { '--quiet' } or {},
            env = {
              DOTENV_CONFIG_QUIET = playwright_quiet and 'true' or 'false',
            },
          },
        })
      end

      require('neotest').setup({
        adapters = { neotest_playwright_adapter() },
        -- 調査のため DEBUG に引き上げ
        log_level = vim.log.levels.DEBUG,
        -- attachment機能を有効化
        consumers = {
          playwright = require('neotest-playwright.consumers').consumers,
        },
      })

      -- neotest ログファイルのパス確認用 :NeotestLogPath
      vim.api.nvim_create_user_command('NeotestLogPath', function()
        local ok, logging = pcall(require, 'neotest.logging')
        if not ok or not logging._log_path then
          print('neotest logging 未初期化')
          return
        end
        print('neotest log: ' .. logging._log_path)
      end, {})

      -- Playwright quiet トグル (再setup) :NeotestPlaywrightToggleQuiet
      vim.api.nvim_create_user_command('NeotestPlaywrightToggleQuiet', function()
        playwright_quiet = not playwright_quiet
        print('Playwright quiet = ' .. tostring(playwright_quiet) .. ' (再セットアップ中)')
        require('neotest').setup({
          adapters = { neotest_playwright_adapter() },
          log_level = require('neotest').config.log_level, -- 既存維持
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
          -- ファイル名とテスト名を使ってUIモードで実行
          local command = string.format('npx playwright test %s --ui --grep "%s"', 
                                        vim.fn.shellescape(file_path), 
                                        vim.fn.shellescape(test_name))
          print('実行中: ' .. command)
          vim.cmd('T ' .. command)
        else
          -- テスト名が見つからない場合はファイル全体をUIモードで実行
          local command = string.format('npx playwright test %s --ui', vim.fn.shellescape(file_path))
          print('実行中: ' .. command)
          vim.cmd('T ' .. command)
        end
      end

      vim.api.nvim_create_user_command('NeotestRunNearestUI', run_nearest_test_ui, {})

      -- キーマッピング設定
      -- neotestのキーマッピング
      map('n', '<leader>tt', '<Cmd>lua require("neotest").run.run()<CR>', { desc = 'Run nearest test' })
      map('n', '<leader>tf', '<Cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>', { desc = 'Run current file tests' })
      map('n', '<leader>td', '<Cmd>lua require("neotest").run.run({strategy = "dap"})<CR>', { desc = 'Debug nearest test' })
      map('n', '<leader>ts', '<Cmd>lua require("neotest").summary.toggle()<CR>', { desc = 'Toggle test summary' })
      map('n', '<leader>to', '<Cmd>lua require("neotest").output.open({enter = true})<CR>', { desc = 'Open test output' })

      -- カーソル位置のテストをUIモードで実行
      map('n', '<leader>ttu', '<Cmd>NeotestRunNearestUI<CR>', { desc = 'Run nearest test in UI mode' })

      -- neotest-playwright専用のコマンド群
      map('n', '<leader>tp', '<Cmd>NeotestPlaywrightProject<CR>', { desc = 'Playwright project settings' })
      map('n', '<leader>tpr', '<Cmd>NeotestPlaywrightPreset<CR>', { desc = 'Playwright preset' })
      map('n', '<leader>tra', '<Cmd>NeotestPlaywrightRefresh<CR>', { desc = 'Playwright refresh' })

      -- attachment（trace、video）を表示
      map('n', '<leader>ta', '<Cmd>lua require("neotest").playwright.attachment()<CR>', { desc = 'Show playwright attachments' })

      -- プリセットをheadedに設定（ブラウザ表示）
      map('n', '<leader>th', '<Cmd>NeotestPlaywrightPreset<CR>', { desc = 'Set headed preset' })

      -- デバッグモードでテスト実行
      map('n', '<leader>tdb', '<Cmd>NeotestPlaywrightPreset<CR>', { desc = 'Debug mode test' })

      -- neotest watchモード
      map('n', '<leader>tw', '<Cmd>lua require("neotest").watch.toggle()<CR>', { desc = 'Toggle watch mode (nearest)' })
      map('n', '<leader>tW', '<Cmd>lua require("neotest").watch.toggle(vim.fn.expand("%"))<CR>', { desc = 'Toggle watch mode (file)' })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "typescript",
          "tsx",
        },
        highlight = {
          enable = true,
          -- helpファイルでtreesitterを無効にしてエラーを回避
          disable = { "help" },
        },
        -- Neovim 0.11.0との互換性のため
        auto_install = false,
      }

      -- Workaround: help ファイルで treesitter の自動起動を止める
      vim.api.nvim_create_augroup('fix_help_treesitter', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = 'fix_help_treesitter',
        pattern = 'help',
        callback = function()
          pcall(function() 
            if vim.treesitter and vim.treesitter.stop then 
              vim.treesitter.stop(0) 
            end 
          end)
        end
      })
    end,
  },
}
