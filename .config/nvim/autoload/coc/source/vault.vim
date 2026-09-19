let s:callbacks = {}
let s:next_id = 0
function! coc#source#vault#init() abort
  return {'shortcut': 'Vault', 'priority': 100, 'filetypes': ['markdown', 'thino-capture'], 'triggerCharacters': ['[']}
endfunction
function! coc#source#vault#get_startcol(option) abort
  return luaeval("require('config.vault-completion').startcol(_A)", a:option)
endfunction
function! coc#source#vault#complete(option, cb) abort
  let s:next_id += 1
  let s:callbacks[s:next_id] = a:cb
  call luaeval("require('config.vault-completion').complete(_A[1], _A[2])", [a:option, s:next_id])
endfunction
function! coc#source#vault#finish(id, items) abort
  if has_key(s:callbacks, a:id)
    let Callback = remove(s:callbacks, a:id)
    call Callback(a:items)
  endif
endfunction
