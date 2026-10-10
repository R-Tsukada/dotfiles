return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {},
  cmd = {
    'ClaudeCode', 'ClaudeCodeFocus', 'ClaudeCodeSelectModel',
    'ClaudeCodeAdd', 'ClaudeCodeSend', 'ClaudeCodeTreeAdd',
    'ClaudeCodeStatus', 'ClaudeCodeStart', 'ClaudeCodeStop',
    'ClaudeCodeOpen', 'ClaudeCodeClose', 'ClaudeCodeDiffAccept',
    'ClaudeCodeDiffDeny', 'ClaudeCodeCloseAllDiffs',
  },
  keys = {
    { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Claude Codeを開閉' },
    { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Claude Codeへ移動' },
    { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'セッションを選んで再開' },
    { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = '直前のセッションを再開' },
    { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Claude Codeのモデル選択' },
    { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = '現在のファイルをClaude Codeに追加' },
    { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = '選択範囲をClaude Codeに送る' },
    { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Claude Codeの変更差分を承認' },
    { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Claude Codeの変更差分を却下' },
  },
}
