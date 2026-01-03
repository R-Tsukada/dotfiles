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
