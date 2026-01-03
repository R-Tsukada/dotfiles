return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          "typescript",
          "tsx",
        },
        highlight = {
          enable = true,
          -- helpファイルでtreesitterを無効にしてエラーを回避
          disable = { "help" },
        },
        -- Neovim 0.11.0との互換性のため
        auto_install = false,
      }

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
