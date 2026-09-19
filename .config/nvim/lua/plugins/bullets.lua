return {
  'bullets-vim/bullets.vim',
  -- FileTypeイベント後に読み込まれると、同イベントで作るEnterの
  -- バッファローカルマッピングが間に合わない場合があるため常時読み込む。
  lazy = false,
  init = function()
    vim.g.bullets_enabled_file_types = { 'markdown', 'thino-capture' }
    vim.g.bullets_enable_in_empty_buffers = 0
    vim.g.bullets_set_mappings = 0
    vim.g.bullets_line_spacing = 1
    vim.g.bullets_auto_indent_after_colon = 0
    vim.g.bullets_delete_last_bullet_if_empty = 2
    vim.g.bullets_custom_mappings = {
      { 'imap', '<CR>', '<Plug>(bullets-newline)' },
      { 'imap', '<C-t>', '<Plug>(bullets-demote)' },
      { 'imap', '<C-d>', '<Plug>(bullets-promote)' },
    }
  end,
}
