return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      ensure_installed = { "typescript", "tsx" },
      highlight = {
        enable = true,
        disable = { "help" },
      },
      auto_install = false,
    },
    config = function(_, opts)
      require('config.treesitter-compat').setup()
      require('nvim-treesitter.configs').setup(opts)

      -- Workaround: help ファイルで treesitter の自動起動を止める
      vim.api.nvim_create_augroup('fix_help_treesitter', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        group = 'fix_help_treesitter',
        pattern = 'help',
        callback = function()
          pcall(function() 
            if vim.treesitter and vim.treesitter.stop then 
              vim.treesitter.stop(0) 
            end 
          end)
        end
      })
    end
  }
}
