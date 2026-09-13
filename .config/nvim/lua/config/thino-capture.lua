local M = {}
local draft

local function client()
  require('lazy').load({ plugins = { 'obsidian.nvim' } })
  return require('obsidian').get_client()
end

-- Insert at the end of the configured heading, before the next peer heading.
function M.insert(lines, text, stamp, heading)
  local body = vim.split(text, '\n', { plain = true })
  while #body > 0 and body[1]:match('^%s*$') do table.remove(body, 1) end
  while #body > 0 and body[#body]:match('^%s*$') do table.remove(body) end
  assert(#body > 0, 'メモが空です')
  local entry = { '- ' .. stamp .. ' ' .. body[1] }
  for i = 2, #body do entry[#entry + 1] = '  ' .. body[i] end
  local result = vim.deepcopy(lines)
  local at = #result
  if heading ~= '' then
    local start
    for i, line in ipairs(result) do
      if vim.trim(line) == heading then start = i; break end
    end
    if start then
      local level = #(heading:match('^#+') or '#')
      local fence
      for i = start + 1, #result do
        local marker = result[i]:match('^%s*(```+)') or result[i]:match('^%s*(~~~+)')
        if marker then
          if not fence then fence = marker
          elseif marker:sub(1, 1) == fence:sub(1, 1) and #marker >= #fence then fence = nil end
        end
        local hashes = result[i]:match('^(#+)%s')
        if not fence and hashes and #hashes <= level then at = i - 1; break end
      end
    else
      if #result > 0 and result[#result] ~= '' then result[#result + 1] = '' end
      result[#result + 1] = heading
      result[#result + 1] = ''
      at = #result
    end
  end
  while at > 0 and result[at] == '' do at = at - 1 end
  for i = #entry, 1, -1 do table.insert(result, at + 1, entry[i]) end
  return result
end

function M.submit()
  if not draft or not vim.api.nvim_buf_is_valid(draft) then return end
  local text = table.concat(vim.api.nvim_buf_get_lines(draft, 0, -1, false), '\n')
  if vim.trim(text) == '' then vim.notify('メモが空です'); return end
  local ok, err = pcall(function()
    local c = client()
    local now = os.time()
    local path = tostring(c:daily_note_path(now))
    local buf = vim.fn.bufadd(path)
    if vim.fn.filereadable(path) == 0 and not vim.bo[buf].modified then c:daily(0) end
    vim.fn.bufload(buf)
    if not vim.bo[buf].modified then
      vim.api.nvim_buf_call(buf, function() vim.cmd('checktime') end)
    end
    -- 未保存のメモや手動編集を含む、バッファの最新版に追記する。
    local before = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local was_modified = vim.bo[buf].modified
    local heading = vim.env.OBSIDIAN_CAPTURE_HEADING or '## Diary'
    local after = M.insert(before, text, os.date('%H:%M', now), heading)
    local saved, why = pcall(function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, after)
      vim.api.nvim_buf_call(buf, function() vim.cmd('silent write') end)
      assert(not vim.bo[buf].modified, '日次ノートの保存が完了していません')
    end)
    if not saved then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, before)
      -- 保存フックが失敗した場合も、既存の未保存編集を失わない。
      vim.bo[buf].modified = was_modified
      error(why)
    end
    vim.api.nvim_buf_set_lines(draft, 0, -1, false, { '' })
    vim.bo[draft].modified = false
    vim.notify('日次ノートに記録しました: ' .. path)
  end)
  if not ok then vim.notify(tostring(err), vim.log.levels.ERROR) end
end

function M.open()
  if draft and vim.api.nvim_buf_is_valid(draft) then
    local win = vim.fn.bufwinid(draft)
    if win ~= -1 then vim.api.nvim_set_current_win(win); return end
  else
    draft = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(draft, 'thino-capture://daily')
    vim.bo[draft].buftype = 'acwrite'
    vim.bo[draft].bufhidden = 'hide'
    vim.bo[draft].swapfile = false
    vim.bo[draft].filetype = 'thino-capture'
    vim.bo[draft].syntax = 'markdown'
    vim.api.nvim_create_autocmd('BufWriteCmd', { buffer = draft, callback = M.submit })
    vim.keymap.set({ 'n', 'i' }, '<C-s>', M.submit, { buffer = draft, desc = '今日の日次ノートへ記録' })
    vim.keymap.set('n', 'q', function() vim.api.nvim_win_close(0, true) end,
      { buffer = draft, desc = '下書きを保持して閉じる' })
  end
  vim.cmd('botright 45vsplit')
  vim.api.nvim_win_set_buf(0, draft)
  vim.wo.winfixwidth = true
  vim.wo.wrap = true
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.winbar = '今日のメモ │ Ctrl+s / :w で記録 │ q で閉じる'
  vim.cmd('startinsert')
end

return M
