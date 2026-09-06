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
    opts = {
        adapters = {
            gemini = function ()
                return require("codecompanion.adapters").extend("gemini", {
                    env = {
                        api_key = "GEMINI_API_KEY",
                    },
                    schema = {
                        model = {
                            default = "gemini-3.6-flash",
                        },
                    },
                })
            end,
        },
        -- Force chat and inline prompts to use Gemini instead of Copilot
        strategies = {
            chat = {
                adapter = "gemini",
                model = "gemin-3.6-flash"
            },
            inline = {
                adapter = "gemini",
                model = "gemini-3.6-flash"
            },
        },
    },
    keys = {
        { "<leader>aa", "<cmd>CodeCompanionChat toggle<cr>", desc = "Toggle Gemini Chat" },
        { "<leader>ai", "<cmd>codecompanion<cr>", mode = { "n", "v" }, desc = "Inline Gemini Prompt"},
    }
}
