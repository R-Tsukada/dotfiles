return {
  'OXY2DEV/markview.nvim',

  -- markview itself already controls when buffers are rendered. Loading the
  -- plugin eagerly avoids a visible delay the first time preview is enabled.
  lazy = false,

  opts = {
    preview = {
      icon_provider = 'internal',
    },
  },

  keys = {
    { '<leader>mp', '<Cmd>Markview toggle<CR>', desc = 'Markdownプレビューを開閉' },
    { '<leader>ms', '<Cmd>Markview splitToggle<CR>', desc = 'Markdownを左右分割でプレビュー' },
  },
}
