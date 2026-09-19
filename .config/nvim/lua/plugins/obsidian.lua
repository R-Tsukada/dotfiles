return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  config = function(_, opts)
    require('config.obsidian-selection').setup()
    require('obsidian').setup(opts)
  end,
  cmd = {
    "ObsidianOpen",
    "ObsidianNew",
    "ObsidianSearch",
    "ObsidianToday",
  },
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",

    -- see below for full list of optional dependencies 👇
  },
  keys = {
    { "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New Obsidian note" },
    { "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian app" },
    { "<leader>of", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick Switch" },
    { "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search Obsidian notes" },
    { "<leader>ot", "<cmd>ObsidianToday<cr>", desc = "Open/Create Today's note" },
    { "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Open/Create Yesterday's note" },
    { "<leader>om", "<cmd>ObsidianTomorrow<cr>", desc = "Open/Create Tomorrow's note" },
    { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Show Backlinks" },
    { "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Show Links" },
    { "<leader>oc", "<cmd>ObsidianToggleCheckbox<cr>", desc = "Toggle Checkbox" },
    -- ビジュアルモード用
    { "<leader>ol", "<cmd>ObsidianLink<cr>", mode = "v", desc = "Create link from selection" },
    { "<leader>on", "<cmd>ObsidianExtractNote<cr>", mode = "v", desc = "Extract selection to new note" },
  },
  opts = {
    -- 編集中はMarkdown記号をそのまま表示する。整形表示はmd-renderを使う。
    ui = { enable = false },
    -- notes_subdir を指定しないため、通常の新規・抽出ノートはVault直下。
    new_notes_location = "notes_subdir",
    workspaces = {
      {
        name = "personal",
        path = os.getenv("OBSIDIAN_VAULT_PATH") or error("OBSIDIAN_VAULT_PATH environment variable is not set"),
        overrides = {
          daily_notes = {
            -- Vault内の相対パス。PCごとに環境変数で上書きできる。
            folder = os.getenv("OBSIDIAN_DAILY_NOTES_FOLDER") or "valut_cloud/Daily",
            template = "DailyNoteTemplate.md",
          },
        },
      },
      -- {
      --   name = "work",
      --   path = "~/vaults/work",
      -- },
    },

    templates = {
      folder = "Config/Templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
    },

    picker = {
      name = "telescope.nvim",
    },

    note_id_func = function(title)
      if title ~= nil then
        return title
      else
        return tostring(os.time())
      end
    end,
  },
}
