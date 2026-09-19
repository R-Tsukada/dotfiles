local M = {}

function M.context(option)
  local before = option.line:sub(1, option.colnr - 1)
  local start, query = before:match('.*()%[%[([^%[%]|#]*)$')
  if not start then return end
  return { col = start + 1, query = query, after = option.line:sub(option.colnr) }
end

function M.startcol(option)
  local context = M.context(option)
  return context and context.col or -1
end

function M.items(client, notes, context, bufnr)
  local items = {}
  local current = vim.api.nvim_buf_get_name(bufnr)
  local suffix = context.after:sub(1, 2) == ']]' and ''
    or (context.after:sub(1, 1) == ']' and ']' or ']]')
  for _, note in ipairs(notes) do
    local relative = client:vault_relative_path(note.path)
    if relative and tostring(note.path) ~= current then
      local target = tostring(relative):gsub('%.md$', '')
      if not target:find('[%[%]|#\n\r]') then
        local name = target:match('[^/]+$')
        local labels = { name }
        vim.list_extend(labels, note.aliases or {})
        items[#items + 1] = {
          word = target .. suffix, abbr = name, menu = '[Vault] ' .. target,
          filterText = table.concat(labels, ' '),
          info = '別名: ' .. table.concat(note.aliases or {}, ', '), dup = 1,
        }
      end
    end
  end
  table.sort(items, function(a, b) return a.word < b.word end)
  return items
end

function M.complete(option, id)
  local function finish(items)
    vim.schedule(function() vim.fn['coc#source#vault#finish'](id, items) end)
  end
  local context = M.context(option)
  if not context or not vim.env.OBSIDIAN_VAULT_PATH or vim.env.OBSIDIAN_VAULT_PATH == '' then
    finish({}); return
  end
  local ok = pcall(function()
    require('lazy').load({ plugins = { 'obsidian.nvim' } })
    local client = require('obsidian').get_client()
    client:find_notes_async(context.query, function(notes)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(option.bufnr) then finish({}); return end
        local success, items = pcall(M.items, client, notes, context, option.bufnr)
        finish(success and items or {})
      end)
    end)
  end)
  if not ok then finish({}) end
end

return M
