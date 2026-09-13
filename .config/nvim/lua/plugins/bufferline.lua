return {
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      vim.opt.termguicolors = true
      require("bufferline").setup{}

      vim.keymap.set('n', '<Leader>n', ':bnext<CR>', { desc = 'Next buffer' })
      vim.keymap.set('n', '<Leader>p', ':bprevious<CR>', { desc = 'Previous buffer' })
      vim.keymap.set('n', '<Leader>bd', ':bdelete<CR>', { desc = 'Close buffer' })
    end
  }
}
