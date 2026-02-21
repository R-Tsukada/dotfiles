return {
  {
    'lambdalisue/fern.vim',
    -- 読み込み前(init)にグローバル変数を設定する必要があることが多いです
    init = function()
      -- 隠しファイルをデフォルトで表示する (1=表示, 0=非表示)
      vim.g["fern#default_hidden"] = 1
    end,
    -- または config の中でも効く場合がありますが、init推奨
    config = function()
      -- その他のキーマッピングなど
    end,
    keys = {
      { '<Leader>e', '<Cmd>Fern . -drawer<CR>', desc = 'Open Fern drawer' },
      { '<Leader>E', '<Cmd>Fern . -drawer -reveal=%<CR>', desc = 'Open Fern drawer and reveal current file' },
    },
  },
}
