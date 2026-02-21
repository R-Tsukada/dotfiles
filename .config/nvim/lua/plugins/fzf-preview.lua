return {
  'yuki-yano/fzf-preview.vim',
  branch = 'release/rpc',
  dependencies = {
    'junegunn/fzf',
    'junegunn/fzf.vim',
  },
  build = ':UpdateRemotePlugins',
  config = function()
    -- fzf-preview.vim の設定
    vim.g.fzf_preview_use_dev_icons = 1
    
    -- キーマッピング
    vim.keymap.set('n', '<leader>ff', '<cmd>FzfPreviewProjectFilesRpc<CR>', { desc = 'FzfPreview: Project files' })
    vim.keymap.set('n', '<leader>fg', '<cmd>FzfPreviewProjectGrepRpc<CR>', { desc = 'FzfPreview: Grep' })
    vim.keymap.set('n', '<leader>fb', '<cmd>FzfPreviewBuffersRpc<CR>', { desc = 'FzfPreview: Buffers' })
    vim.keymap.set('n', '<leader>fh', '<cmd>FzfPreviewCommandPaletteRpc<CR>', { desc = 'FzfPreview: Command palette' })
  end,
}
