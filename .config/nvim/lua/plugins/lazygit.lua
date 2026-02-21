return {
  "kdheepak/lazygit.nvim",
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },
  -- 起動に必要な依存プラグイン
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- キーマッピングの例（スペース + g + g で起動）
  keys = {
    { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
  }
}
