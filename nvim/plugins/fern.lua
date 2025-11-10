-- fern.vim設定（Lua版）
local map = vim.keymap.set

-- fern.vimキーマッピング
map('n', '<Leader>e', '<Cmd>Fern . -drawer<CR>', { silent = true, desc = 'Open Fern drawer' })
map('n', '<Leader>E', '<Cmd>Fern . -drawer -reveal=%<CR>', { silent = true, desc = 'Open Fern drawer and reveal current file' })
