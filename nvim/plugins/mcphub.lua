-- MCPHub設定
require("mcphub").setup({
  config_file = '~/.config/nvim/mcphub_config.json',
  global_env = {
    ["OBSIDIAN_API_KEY"] = "7757d380f2bed6ae1cf261dedb5d57bd069b2e798fb201d8c1e7a2c13f08359e",
    ["OBSIDIAN_HOST"] = "127.0.0.1",
    ["OBSIDIAN_PORT"] = "27124"
  },
  port = 37373,

  --WSL用設定
  auto_approuve = function(params)
    if params.server_name == "playwright" then
      return true
    end
    return false
  end,

  extensions = {
    copilotchat = {
      enabled = true,
      convert_tools_to_functions = true,
      convert_resources_to_functions = true, -- Convert MCP resources to CopilotChat functions  
      add_mcp_prefix = false,
    }
  },
})
