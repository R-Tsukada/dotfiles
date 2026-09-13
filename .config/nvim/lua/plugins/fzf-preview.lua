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
    vim.keymap.set('n', '<leader>ff', function()
      -- ProjectFiles は Git 管理外で内部エラーになるため検索方法を切り替える。
      vim.fn.system({ 'git', '-C', vim.fn.getcwd(), 'rev-parse', '--show-toplevel' })
      local command = vim.v.shell_error == 0
          and 'FzfPreviewProjectFilesRpc' or 'FzfPreviewDirectoryFilesRpc'
      vim.cmd(command)
    end, { desc = 'FzfPreview: ファイル検索（Git管理外にも対応）' })
    -- ProjectGrep は ripgrep の検索語を引数として必要とする。
    -- コマンドラインを開いて入力してから実行する。
    vim.keymap.set('n', '<leader>fg', ':<C-u>FzfPreviewProjectGrepRpc ', { desc = 'FzfPreview: Grep' })
    vim.keymap.set('n', '<leader>fb', '<cmd>FzfPreviewBuffersRpc<CR>', { desc = 'FzfPreview: Buffers' })
    vim.keymap.set('n', '<leader>fh', '<cmd>FzfPreviewCommandPaletteRpc<CR>', { desc = 'FzfPreview: Command palette' })
  end,
}
