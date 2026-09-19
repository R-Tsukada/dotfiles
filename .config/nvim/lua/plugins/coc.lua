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
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('vault_completion_keys', { clear = true }),
        pattern = { 'markdown', 'thino-capture' },
        callback = function(ev)
          for key, action in pairs({ ['<C-n>'] = 'next', ['<C-p>'] = 'prev', ['<C-y>'] = 'confirm' }) do
            local call = action == 'confirm' and 'coc#pum#confirm()' or ('coc#pum#' .. action .. '(1)')
            vim.keymap.set('i', key, 'coc#pum#visible() ? ' .. call .. ' : "' .. key:gsub('<', '\\<') .. '"',
              { buffer = ev.buf, expr = true, silent = true, desc = 'Coc補完: ' .. action })
          end
        end,
      })
      vim.keymap.set('n', 'gd', '<Plug>(coc-definition)',
        { silent = true, desc = '定義へジャンプ（Coc）' })
      vim.keymap.set('n', '<leader>fo', '<Cmd>CocCommand fzf-preview.CocOutline<CR>',
        { silent = true, desc = 'アウトラインを検索（TypeScript / Markdown）' })
      vim.keymap.set('n', '<leader>fO', '<Cmd>CocOutline<CR>',
        { silent = true, desc = 'アウトラインをサイドバーに表示' })
    end,
  }
}
