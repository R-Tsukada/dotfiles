return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreview', 'MarkdownPreviewToggle', 'MarkdownPreviewStop' },
  ft = 'markdown',
  build = function(plugin)
    local output = vim.fn.system({ 'npm', 'install', '--prefix', plugin.dir .. '/app', '--omit=dev' })
    if vim.v.shell_error ~= 0 then error(output) end
    -- Prefer Node.js if a binary from an earlier installation remains.
    for _, path in ipairs(vim.fn.glob(plugin.dir .. '/app/bin/markdown-preview-*', false, true)) do
      vim.fn.setfperm(path, 'rw-r--r--')
    end
  end,
  init = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_echo_preview_url = 1
    -- Use the Windows browser when running Neovim inside WSL.
    if vim.fn.has('wsl') == 1 then
      vim.g.mkdp_browser = 'wslview'
    end
  end,
  keys = {
    { '<leader>mb', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdownをブラウザでプレビュー' },
    { '<leader>mB', '<cmd>MarkdownPreviewStop<cr>', desc = 'ブラウザプレビューを停止' },
  },
}
