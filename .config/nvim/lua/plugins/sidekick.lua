return {
  "folke/sidekick.nvim",
  event = "VeryLazy",
  opts = {
    cli = {
      mux = {
        enabled = true,
        backend = "tmux",
      },
    },
  },
  keys = {
    { "<leader>aa", function() require("sidekick.cli").toggle() end, desc = "Sidekick: AI CLI を開く" },
    { "<leader>as", function() require("sidekick.cli").select() end, desc = "Sidekick: CLI ツールを選択" },
    { "<leader>ap", function() require("sidekick.cli").prompt() end, desc = "Sidekick: プロンプトを選択" },
  },
}
