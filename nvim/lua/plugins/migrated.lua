return {
  { 'vim-jp/vimdoc-ja' },
  { 'junegunn/fzf', build = './install --all' },
  { 'sainnhe/gruvbox-material' },
  {
    'ghifarit53/tokyonight-vim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.tokyonight_style = 'night'
      vim.g.tokyonight_enable_italic = 1
      vim.cmd('colorscheme tokyonight')
    end
  },
  { 'Yggdroot/indentLine' },

  { 'nvim-lua/plenary.nvim' },
  { 'antoinemadec/FixCursorHold.nvim' },

  { 'mfussenegger/nvim-dap' },
  { 'theHamsta/nvim-dap-virtual-text' },
  { 'rcarriga/nvim-dap-ui' },

  { 'thinca/vim-qfreplace' },
  { 'ravitemer/mcphub.nvim', build = function()
    dofile(vim.fn.stdpath('data') .. '/lazy/mcphub.nvim/bundled_build.lua')
  end },
  { 'kdheepak/lazygit.nvim' }
}
