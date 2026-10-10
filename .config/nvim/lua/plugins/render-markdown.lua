return {
  'MeanderingProgrammer/render-markdown.nvim',
  lazy = false,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    anti_conceal = {
      enabled = true,
      above = 1,
      below = 1,
      ignore = {
        check_icon = false,
        check_scope = false,
        table_border = false,
        virtual_lines = false,
      },
    },
    heading = {
      icons = { '① ', '② ', '③ ', '④ ', '⑤ ', '⑥ ' },
      sign = false,
      backgrounds = { 'DotfilesMarkdownH1', 'DotfilesMarkdownH2', 'DotfilesMarkdownH3', 'DotfilesMarkdownH4', 'DotfilesMarkdownH5', 'DotfilesMarkdownH6' },
      foregrounds = { 'DotfilesMarkdownH1', 'DotfilesMarkdownH2', 'DotfilesMarkdownH3', 'DotfilesMarkdownH4', 'DotfilesMarkdownH5', 'DotfilesMarkdownH6' },
    },
  },
  config = function(_, opts)
    local function highlights()
      -- H1から順に紫・青・青緑・緑・黄褐色・赤紫。
      local backgrounds = { '#403052', '#293F60', '#25494F', '#344A36', '#51452B', '#513340' }
      for level, bg in ipairs(backgrounds) do
        vim.api.nvim_set_hl(0, 'DotfilesMarkdownH' .. level, {
          fg = '#E6EAF2', bg = bg, bold = true, underline = level <= 2,
        })
      end
    end
    highlights()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('dotfiles_markdown_headings', { clear = true }),
      callback = highlights,
    })
    require('render-markdown').setup(opts)
  end,
  keys = {
    { '<leader>mp', '<cmd>RenderMarkdown buf_toggle<cr>', desc = 'Markdown装飾表示を切替' },
  },
}
