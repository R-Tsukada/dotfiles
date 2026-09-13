-- 基本設定のみ（プラグイン非依存）- Lua版
local opt = vim.opt

-- 基本表示設定
vim.cmd('syntax on')

-- 基本オプション
opt.termguicolors = true
opt.updatetime = 500
opt.clipboard:append('unnamedplus')
opt.swapfile = false
opt.number = true
opt.cursorline = true
opt.showmatch = true
opt.laststatus = 2
opt.showmode = true
opt.showcmd = true
opt.ruler = true
opt.whichwrap = 'b,s,h,l,<,>,[,],~'

-- インデント関連（重複除去）
opt.autoindent = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.softtabstop = 2

-- 可視化（最終設定を採用）
opt.list = true
opt.listchars = 'tab:>-,trail:.'

-- CopilotChat.nvim用の補完設定
opt.completeopt = { 'menuone', 'noselect', 'popup' } -- CopilotChat補完用

-- jsonファイルではconcealを無効化
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'json',
  callback = function()
    vim.opt_local.conceallevel = 0
    vim.opt_local.concealcursor = ''
  end,
})

-- Windows用
-- 1. デフォルトのヤンク先をシステムクリップボードに設定
-- これをしないと "+y" のように毎回プラスを指定しないといけなくなります
vim.opt.clipboard = "unnamedplus"

-- 2. WSL側からWindowsのクリップボードを操作する設定
-- win32yank.exe を経由してコピー＆ペーストを行います
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end
