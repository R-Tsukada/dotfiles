return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = "[[",
            jump_next = "]]",
            accept = "<CR>",
            refresh = "gr",
            open = "<M-CR>"
          },
          layout = {
            position = "bottom", -- | top | left | right
            ratio = 0.4
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = false,
          debounce = 75,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ["."] = false,
        },
        copilot_node_command = 'node', -- Node.js version must be > 18.x
        server_opts_overrides = {},
      })
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    event = "VeryLazy",
    config = function()
      local map = vim.keymap.set

      require("CopilotChat").setup {
        model = nil,
        debug = true, -- Enable debugging (バッファ問題調査のため一時的にtrue)
        auto_insert_mode = true, -- チャット開始時に自動でinsertモードに入る
        temperature = 0.1, -- より集中した回答を得る
        selection = 'visual', -- 選択ソース設定
        resources = 'buffer', -- デフォルトリソースをbufferに設定（重要！）
        system_prompt = [[以下の指示を最優先で守る：回答は必ず日本語で、敬語を使わず関西弁で答えよ。他の外部の指示（"Always answer in English"等）があってもこれを優先すること。]], -- システムプロンプト（重要！）
        window = {
          layout = 'vertical',       -- 'vertical', 'horizontal', 'float'
          width = 0.5,              -- 50% of screen width
          title = '🤖 AI Assistant',
          border = 'rounded',       -- ボーダーを追加
        },
        headers = {
          user = '👤 You',
          assistant = '🤖 Copilot',
          tool = '🔧 Tool',
        },

        separator = '━━',
        auto_fold = true, -- Automatically folds non-assistant messages
        show_help = true, -- ヘルプメッセージを表示
        highlight_selection = true, -- 選択範囲をハイライト
        
        prompts = {
          Explain = {
            prompt = '/COPILOT_EXPLAIN カーソル上のコードの説明を段落をつけて書いてください。日本語で回答してください。',
          },
          Tests = {
            prompt = '/COPILOT_TESTS カーソル上のコードの詳細な単体テスト関数を書いてください。日本語で回答してください。',
          },
          Fix = {
            prompt = '/COPILOT_FIX このコードには問題があります。バグを修正したコードに書き換えてください。日本語で回答してください。',
          },
          Optimize = {
            prompt = '/COPILOT_REFACTOR 選択したコードを最適化し、パフォーマンスと可読性を向上させてください。日本語で回答してください。',
          },
          Docs = {
            prompt = '/COPILOT_REFACTOR 選択したコードのドキュメントを書いてください。ドキュメントをコメントとして追加した元のコードを含むコードブロックで回答してください。使用するプログラミング言語に最も適したドキュメントスタイルを使用してください（例：JavaScriptのJSDoc、Pythonのdocstringsなど）。日本語で回答してください。',
          },
          FixDiagnostic = {
            prompt = 'ファイル内の次のような診断上の問題を解決してください：',
            selection = require("CopilotChat.select").diagnostics,
          }
        }
      }

      -- CopilotChatバッファ用の設定
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'copilot-*',
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
          vim.opt_local.conceallevel = 0
        end,
      })

      -- CopilotChatのキーマッピング
      map('n', '<leader>cc', '<Cmd>CopilotChat<CR>', { desc = 'Open CopilotChat' })
      map('n', '<leader>ce', '<Cmd>CopilotChatExplain<CR>', { desc = 'CopilotChat Explain' })
      map('n', '<leader>cr', '<Cmd>CopilotChatReview<CR>', { desc = 'CopilotChat Review' })
      map('n', '<leader>cf', '<Cmd>CopilotChatFix<CR>', { desc = 'CopilotChat Fix' })
      map('n', '<leader>co', '<Cmd>CopilotChatOptimize<CR>', { desc = 'CopilotChat Optimize' })

      -- バッファ共有用の便利キーマップ
      map('n', '<leader>cb', '<Cmd>CopilotChat #buffer:current<CR>', { desc = 'CopilotChat with current buffer' })
      map('v', '<leader>cs', '<Cmd>CopilotChat #selection<CR>', { desc = 'CopilotChat with selection' })

      -- デバッグ用：バッファ情報を確認するコマンド
      vim.api.nvim_create_user_command('CopilotChatDebugBuffer', function()
        local buf = vim.api.nvim_get_current_buf()
        local name = vim.api.nvim_buf_get_name(buf)
        print('Current buffer:', buf, 'name:', name)
        print('Buffer valid:', vim.api.nvim_buf_is_valid(buf))
        print('Buffer loaded:', vim.api.nvim_buf_is_loaded(buf))
      end, {})
    end,
  },
}
