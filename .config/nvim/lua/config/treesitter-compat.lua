local M = {}

function M.setup()
  if vim.fn.has('nvim-0.12') == 0 then return end

  -- 旧 nvim-treesitter の all=false ハンドラーに、0.12で廃止された
  -- 単一ノード形式を渡す。登録APIの差し替えはこのモジュールの読み込み中だけ。
  local query = vim.treesitter.query
  local originals = { add_predicate = query.add_predicate, add_directive = query.add_directive }
  for name, register in pairs(originals) do
    query[name] = function(id, handler, opts)
      if type(opts) == 'table' and opts.all == false then
        local legacy_handler = handler
        handler = function(match, ...)
          local nodes = {}
          for capture, value in pairs(match) do
            nodes[capture] = type(value) == 'table' and value[#value] or value
          end
          return legacy_handler(nodes, ...)
        end
      end
      return register(id, handler, opts)
    end
  end
  -- plugin/*.lua ですでに登録されていても、互換ハンドラーに置き換える。
  package.loaded['nvim-treesitter.query_predicates'] = nil
  local ok, err = pcall(require, 'nvim-treesitter.query_predicates')
  for name, register in pairs(originals) do query[name] = register end
  if not ok then error(err) end
end

return M
