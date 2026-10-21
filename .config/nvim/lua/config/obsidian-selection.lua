local M = {}
local installed = false

function M.setup()
  if installed then return end
  local util = require('obsidian.util')
  local original = util.get_visual_selection
  util.get_visual_selection = function(opts)
    local mode = vim.fn.mode()
    local linewise = mode == 'V'
      or (mode ~= 'v' and mode ~= '\022' and vim.fn.visualmode() == 'V')
    local selection = original(opts)
    if selection and linewise then
      -- obsidian.nvim v3.9.0 は V の列を 0 / 999 にし、下方向の選択で
      -- 入れ替えてしまう。戻り値は開始列が1始まり、終了列が末尾バイト。
      selection.cscol = 1
      selection.cecol = #selection.lines[#selection.lines]
      selection.selection = table.concat(selection.lines, '\n')
    end
    return selection
  end
  installed = true
end

function M.extract()
  M.setup()
  local util = require('obsidian.util')
  local selection = util.get_visual_selection()
  if not selection or selection.selection == '' then return end
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local tick = vim.api.nvim_buf_get_changedtick(buf)
  -- get_visual_selection queues Esc. Open the prompt after that key is handled.
  vim.schedule(function()
    require('snacks.input').input({ prompt = '抽出先ノートのタイトル' }, function(value)
      if value == nil then return end
      local title = vim.trim(value)
      if title == '' then
        vim.notify('タイトルが空のため抽出を中止しました', vim.log.levels.WARN)
        return
      end
      if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win)
        or vim.api.nvim_win_get_buf(win) ~= buf
        or vim.api.nvim_buf_get_changedtick(buf) ~= tick then
        vim.notify('元のノートが変更されたため抽出を中止しました', vim.log.levels.WARN)
        return
      end
      -- The popup changes the active buffer and visual marks. Pass the captured
      -- selection to the original extractor only for this synchronous call.
      local original = util.get_visual_selection
      util.get_visual_selection = function() return selection end
      local ok, err = pcall(vim.api.nvim_win_call, win, function()
        require('obsidian.commands.extract_note')(require('obsidian').get_client(), { args = title })
      end)
      util.get_visual_selection = original
      if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
    end)
  end)
end

return M
