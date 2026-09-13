local M = {}

function M.open()
  local lines = {
    'Nvim 操作一覧',
    '',
    'Space は順番に押すキーです（例: Space → f → f）。大文字・小文字は区別します。',
    'q または Esc で閉じます。通常の /検索 も使えます。',
    '',
    '基本操作',
    '  Ctrl+s          保存（CopilotChat の挿入モードでは送信）',
    '  Ctrl+w h/j/k/l  分割ウィンドウ間の移動',
    '  Ctrl+\\          ToggleTerm の開閉',
    '  :T [コマンド]   下分割のターミナルを開く',
    '  ターミナル: Esc で入力を抜ける / i で入力に戻る',
    '  Esc Esc         検索ハイライト切り替え',
    '  m{文字}         マーク作成 / ; は f・t 検索を繰り返す',
    '',
    '変更したキー',
    '  Space p         前のバッファ（旧 Space b）',
    '  Space tu        Playwright UI（旧 Space ttu）',
    '  Space tP        プリセット選択（旧 Space tpr / th / tdb）',
    '  Space td        DAP の動作確認まで未割り当て',
    '',
    '現在の Space キーマップ（プラグイン読み込み状態を含む）',
  }
  local entries = {}
  for _, mode in ipairs({ 'n', 'x', 'v' }) do
    for _, mapping in ipairs(vim.api.nvim_get_keymap(mode)) do
      if mapping.lhs:sub(1, 1) == ' ' and #mapping.lhs > 1 then
        entries[#entries + 1] = {
          key = mapping.lhs:sub(2),
          mode = mode,
          text = mapping.desc or mapping.rhs or '(Lua callback)',
        }
      end
    end
  end
  table.sort(entries, function(a, b)
    if a.key == b.key then return a.mode < b.mode end
    return a.key < b.key
  end)
  for _, entry in ipairs(entries) do
    lines[#lines + 1] = string.format('  %-6s Space %-6s %s',
      entry.mode == 'n' and '通常' or '選択', entry.key, entry.text)
  end
  vim.list_extend(lines, {
    '',
    '確認コマンド',
    '  :Lazy                       プラグインの状態',
    '  :messages                   エラー・通知の履歴',
    '  :checkhealth                環境診断',
    '  :verbose nmap <Space>ff     キーの割り当て元',
    '  :KeymapHelp                 この操作一覧を開く',
  })
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  local width = math.max(1, math.min(110, vim.o.columns - 4))
  local height = math.max(1, math.min(#lines, vim.o.lines - 4))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor', style = 'minimal', border = 'rounded',
    width = width, height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
  })
  vim.wo[win].wrap = true
  for _, key in ipairs({ 'q', '<Esc>' }) do
    vim.keymap.set('n', key, function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end, { buffer = buf, silent = true, nowait = true })
  end
end

return M
