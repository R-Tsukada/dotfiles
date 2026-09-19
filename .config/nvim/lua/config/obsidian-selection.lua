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

return M
