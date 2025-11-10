-- coc.nvim 完全設定（拡張・キーマップ・autocmd）- Lua版
local map = vim.keymap.set

-- coc拡張設定
vim.g.coc_global_extensions = {
  'coc-tsserver',
  'coc-eslint', 
  'coc-prettier',
  'coc-git',
  'coc-fzf-preview',
  'coc-lists'
}

-- キーマップ
map('i', '<C-Space>', '<Cmd>call coc#refresh()<CR>', { silent = true, expr = true, desc = 'Trigger coc completion' })
map('n', 'K', '<Cmd>call v:lua.show_documentation()<CR>', { silent = true, desc = 'Show documentation' })
map('n', '<Plug>(lsp)rn', '<Plug>(coc-rename)', { silent = true, desc = 'Rename symbol' })
map('n', '<Plug>(lsp)a', '<Plug>(coc-codeaction-cursor)', { silent = true, desc = 'Code action' })

-- fzf-preview統合
vim.env.BAT_THEME = 'gruvbox-dark'
vim.env.FZF_PREVIEW_PREVIEW_BAT_THEME = 'gruvbox-dark'

-- fzf-preview キーマップ
map('n', '<Plug>(ff)r', '<Cmd>CocCommand fzf-preview.ProjectFiles<CR>', { silent = true, desc = 'Project files' })
map('n', '<Plug>(ff)s', '<Cmd>CocCommand fzf-preview.GitStatus<CR>', { silent = true, desc = 'Git status' })
map('n', '<Plug>(ff)gg', '<Cmd>CocCommand fzf-preview.GitActions<CR>', { silent = true, desc = 'Git actions' })
map('n', '<Plug>(ff)b', '<Cmd>CocCommand fzf-preview.Buffers<CR>', { silent = true, desc = 'Buffers' })
map('n', '<Plug>(ff)f', ':<C-u>CocCommand fzf-preview.ProjectGrep --add-fzf-arg=--exact --add-fzf-arg=--no-sort<Space>', { desc = 'Project grep' })

-- LSP関連キーマップ
map('n', '<Plug>(lsp)q', '<Cmd>CocCommand fzf-preview.CocCurrentDiagnostics<CR>', { silent = true, desc = 'Diagnostics' })
map('n', '<Plug>(lsp)rf', '<Cmd>CocCommand fzf-preview.CocReferences<CR>', { silent = true, desc = 'References' })
map('n', '<Plug>(lsp)d', '<Cmd>CocCommand fzf-preview.CocDefinition<CR>', { silent = true, desc = 'Definition' })
map('n', '<Plug>(lsp)t', '<Cmd>CocCommand fzf-preview.CocTypeDefinition<CR>', { silent = true, desc = 'Type definition' })
map('n', '<Plug>(lsp)o', '<Cmd>CocCommand fzf-preview.CocOutline --add-fzf-arg=--exact --add-fzf-arg=--no-sort<CR>', { silent = true, desc = 'Outline' })
map('n', '<Leader>q', ':copen<CR>', { silent = true, desc = 'Open quickfix list' })

-- グローバル関数定義
function _G.show_documentation()
  local ft = vim.bo.filetype
  if ft == 'vim' or ft == 'help' then
    vim.cmd('h ' .. vim.fn.expand('<cword>'))
  elseif vim.fn['coc#rpc#ready']() then
    vim.fn.CocActionAsync('doHover')
  end
end

-- TypeScript用設定関数
local function coc_typescript_settings()
  map('n', '<Plug>(lsp)f', ':<C-u>CocCommand eslint.executeAutofix<CR>:CocCommand prettier.formatFile<CR>', 
      { buffer = true, silent = true, desc = 'Format TypeScript file' })
end

-- TypeScript autocmd
local coc_group = vim.api.nvim_create_augroup('coc_typescript', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = coc_group,
  pattern = { 'typescript', 'typescriptreact' },
  callback = coc_typescript_settings,
  desc = 'Set TypeScript-specific coc keymaps'
})
