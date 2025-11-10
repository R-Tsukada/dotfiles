-- プラグイン定義（重複除去済み、カラースキーム除去）- Lua版
-- vim-plugはVimscript専用のため、lua hereドキュメントで呼び出し

vim.cmd([[
call plug#begin('~/.local/share/nvim/site/autoload')

" 基本プラグイン
Plug 'vim-jp/vimdoc-ja'
Plug 'junegunn/fzf', {'dir': '~/.fzf_bin', 'do': './install --all'}
Plug 'sainnhe/gruvbox-material'
Plug 'ghifarit53/tokyonight-vim'
Plug 'Yggdroot/indentLine'

" 必須依存（重複除去）
Plug 'nvim-lua/plenary.nvim'
Plug 'antoinemadec/FixCursorHold.nvim'

" 開発環境
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'lambdalisue/fern.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" テスト関連
Plug 'nvim-neotest/nvim-nio' 
Plug 'nvim-neotest/neotest'
Plug 'thenbe/neotest-playwright'

" デバッグ
Plug 'mfussenegger/nvim-dap'
Plug 'theHamsta/nvim-dap-virtual-text'
Plug 'rcarriga/nvim-dap-ui'

" AI関連
Plug 'github/copilot.vim'
Plug 'CopilotC-Nvim/CopilotChat.nvim'

" Quickfix拡張
Plug 'thinca/vim-qfreplace'

" その他
Plug 'ravitemer/mcphub.nvim', { 'do': 'npm install -g mcp-hub@latest' }
Plug 'kdheepak/lazygit.nvim'

call plug#end()
]])

-- 注意: カラースキームは init.vim の最後で適用
