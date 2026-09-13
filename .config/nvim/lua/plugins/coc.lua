return {
  {
    "neoclide/coc.nvim",
    branch = "release",
    init = function()
      -- TypeScript/TSX と Markdown のシンボルを fzf-preview に渡す。
      local extensions = vim.g.coc_global_extensions or {}
      for _, name in ipairs({ "coc-tsserver", "@yaegassy/coc-marksman", "coc-fzf-preview" }) do
        if not vim.tbl_contains(extensions, name) then
          extensions[#extensions + 1] = name
        end
      end
      vim.g.coc_global_extensions = extensions
    end,
    config = function()
      vim.keymap.set('n', 'gd', '<Plug>(coc-definition)',
        { silent = true, desc = '定義へジャンプ（Coc）' })
      vim.keymap.set('n', '<leader>fo', '<Cmd>CocCommand fzf-preview.CocOutline<CR>',
        { silent = true, desc = 'アウトラインを検索（TypeScript / Markdown）' })
      vim.keymap.set('n', '<leader>fO', '<Cmd>CocOutline<CR>',
        { silent = true, desc = 'アウトラインをサイドバーに表示' })
    end,
  }
}
