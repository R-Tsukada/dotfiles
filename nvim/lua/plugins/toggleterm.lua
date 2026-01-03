return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup({
      -- ターミナルのサイズ
      size = function(term)
        if term.direction == 'horizontal' then
          return 15
        elseif term.direction == 'vertical' then
          return vim.o.columns * 0.4
        end
      end,

      -- 起動キーの設定（重要）
      -- <C-\> は押しやすく、他のキーと競合しにくいのでデファクトスタンダードです
      open_mapping = [[<c-\>]],

      -- シェルの指定（PowerShellやfishなどを指定したい場合）
      -- shell = vim.o.shell,

      -- ターミナルウィンドウ内でのハイライト設定
      highlights = {
        -- 必要に応じてボーダーの色などを変えられます
        -- Normal = { guibg = "<VALUE-HERE>" },
      },

      -- ウィンドウの開き方 ('vertical' | 'horizontal' | 'tab' | 'float')
      direction = 'vertical',

      -- フローティングウィンドウの設定
      float_opts = {
        border = 'curved', -- 'single' | 'double' | 'shadow' | 'curved' ...
        width = 120,
        height = 30,
        winblend = 3, -- 透明度
      },

      -- ターミナルモードでインサートモードを維持するか
      start_in_insert = true,
    })
  end,
}
