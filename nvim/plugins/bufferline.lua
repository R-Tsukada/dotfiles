vim.opt.termguicolors = true
require("bufferline").setup{}

vim.keymap.set('n', '<Leader>n', ':bnext<CR>')
vim.keymap.set('n', '<Leader>b', ':bprevious<CR>')
vim.keymap.set('n', '<Leader>bd', ':bdelete<CR>')
