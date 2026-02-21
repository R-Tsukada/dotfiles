
require("config.options")
require("config.lazy")
require("config.keymaps")

-- カラースキーム設定（プラグイン読み込み後）
vim.opt.termguicolors = true
vim.g.tokyonight_style = 'night' -- night, storm, day から選択
vim.g.tokyonight_enable_italic = 1
vim.cmd('colorscheme tokyonight')
-- -- vim.cmd('colorscheme gruvbox-material')
-- -- True Colorを有効にする (必須)

-- neotest設定をlazy.nvimの後に読み込む
vim.defer_fn(function()
  require("config.neotest-setup")
end, 500)

-- Normalモード: Ctrl+s で保存
vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', { silent = true })

-- Insertモード: Ctrl+s で保存（Insertモードを維持したまま保存）
vim.keymap.set('i', '<C-s>', '<cmd>w<CR>', { silent = true })

