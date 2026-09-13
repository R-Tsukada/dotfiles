return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "thenbe/neotest-playwright",
    },
    event = "VeryLazy",
    config = function()
      require("config.neotest-setup")
    end,
  },
}
