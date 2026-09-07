local ok, secrets = pcall(require, "core.secrets")
if ok and secrets and secrets.GEMINI_API_KEY then
    vim.env.GEMINI_API_KEY = secrets.GEMINI_API_KEY
end

return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("codecompanion").setup({
            strategies = {
                chat = {
                    adapter = {
                        name = "gemini",
                        model = "gemini-3.6-flash",
                    }
                },
                inline = {
                    adapter = {
                        name = "gemini",
                        model = "gemini-3.6-flash",
                    }
                },
            },
            adapters = {
                gemini = function ()
                    return require("codecompanion.adapters").extend("gemini", {
                        schema = {
                            model = {
                                default = "gemini-3.6-flash",
                                choices = {
                                    "gemini-3.6-flash",
                                    "gemini-3.5-flash",
                                    "gemini-3.1-flash-lite",
                                }
                            }
                        }
                    })
                end
            }
        })
    end,
    keys = {
        { "<leader>aa", "<cmd>CodeCompanionChat toggle<cr>", desc = "Toggle Gemini Chat" },
        { "<leader>ai", "<cmd>codecompanion<cr>", mode = { "n", "v" }, desc = "Inline Gemini Prompt"},
    }
}
