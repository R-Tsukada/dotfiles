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

-- グローバルキーマップとリーダー設定（Lua版）
local map = vim.keymap.set
local cmd = vim.api.nvim_create_user_command

-- リーダーキー設定
vim.g.mapleader = " "

-- ターミナル関連
map('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- ターミナルコマンド定義
cmd('T', function(opts)
  vim.cmd('split')
  vim.cmd('wincmd j')
  vim.cmd('resize 20')
  if opts.args and opts.args ~= '' then
    vim.cmd('terminal ' .. opts.args)
  else
    vim.cmd('terminal')
  end
end, { nargs = '*', desc = 'Open terminal in split' })

-- 検索関連（重複除去 - 1つに統合）
map('n', '<Esc><Esc>', ':<C-u>set nohlsearch!<CR>', { silent = true, desc = 'Toggle search highlight' })

-- 入力補助
map('i', '(', '()<Left>', { desc = 'Auto close parentheses' })
map('i', '{', '{}<Left>', { desc = 'Auto close braces' })
map('i', '[', '[]<Left>', { desc = 'Auto close brackets' })
map('i', "'", "''<Left>", { desc = 'Auto close single quotes' })
map('i', '"', '""<Left>', { desc = 'Auto close double quotes' })

-- Quickfix関連
-- Quickfixウィンドウ内でのキーマップを設定
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'qf',
  callback = function()
    vim.keymap.set('n', 'r', ':Qfreplace<CR>', { buffer = true, silent = true, desc = 'Replace in quickfix' })
  end,
  desc = 'Quickfix window keymaps'
})

-- プラグイン用プレフィックス
map('n', '<Leader>', '<Nop>')
map('x', '<Leader>', '<Nop>')
map('n', '<Plug>(lsp)', '<Nop>')
map('x', '<Plug>(lsp)', '<Nop>')
map('n', 'm', '<Plug>(lsp)')
map('x', 'm', '<Plug>(lsp)')
map('n', '<Plug>(ff)', '<Nop>')
map('x', '<Plug>(ff)', '<Nop>')
map('n', ';', '<Plug>(ff)')
map('x', ';', '<Plug>(ff)')

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
