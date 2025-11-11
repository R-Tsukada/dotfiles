dofile(vim.fn.stdpath('config') .. '/core/options.lua')
dofile(vim.fn.stdpath('config') .. '/core/keymaps.lua')
dofile(vim.fn.stdpath('config') .. '/plugins/manager.lua')
dofile(vim.fn.stdpath('config') .. '/plugins/coc.lua')
dofile(vim.fn.stdpath('config') .. '/plugins/fern.lua')
dofile(vim.fn.stdpath('config') .. '/plugins/copilot.lua')
dofile(vim.fn.stdpath('config') .. '/plugins/mcphub.lua')
dofile(vim.fn.stdpath('config') .. '/plugins/neotest.lua')
-- vim.cmd('colorscheme gruvbox-material')
-- True Colorを有効にする (必須)
vim.opt.termguicolors = true
vim.g.tokyonight_style = 'night' -- night, storm, day から選択
vim.g.tokyonight_enable_italic = 1
vim.cmd('colorscheme tokyonight')
