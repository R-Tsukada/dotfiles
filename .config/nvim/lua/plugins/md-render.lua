return {
  'delphinus/md-render.nvim',
  version = '*',
  cmd = 'MdRender',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    { 'delphinus/budoux.lua', version = '*' },
  },
  keys = {
    { '<leader>mp', '<Plug>(md-render-preview)', desc = 'Markdownプレビューを開閉' },
    { '<leader>mt', '<Plug>(md-render-preview-tab)', desc = 'Markdownを別タブでプレビュー' },
    { '<leader>ms', '<Cmd>vert MdRender split<CR>', desc = 'Markdownソースとプレビューを左右に表示' },
    { '<leader>md', '<Plug>(md-render-demo)', desc = 'Markdownプレビューのデモ' },
  },
}
