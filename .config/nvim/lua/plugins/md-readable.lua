return {
  'takeshiD/md-readable.nvim',
  cmd = 'MdReadable',
  opts = {},
  keys = {
    { '<leader>mp', '<cmd>MdReadable<cr>', desc = 'Markdown閲覧画面を開く' },
    { '<leader>ms', '<cmd>MdReadable vert<cr>', desc = 'Markdownを左右分割で閲覧' },
    { '<leader>mf', '<cmd>MdReadable float<cr>', desc = 'Markdownをフローティングで閲覧' },
    { '<leader>me', '<cmd>MdReadable source<cr>', desc = 'Markdownの元の編集位置に戻る' },
    { '<leader>mq', '<cmd>MdReadable close<cr>', desc = 'Markdown閲覧画面を閉じる' },
  },
}
