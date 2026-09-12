-- markdown.lua

return {
    -- Browser Live Preview
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        -- Runs automatically on any machine during :Lazy install / sync
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
            vim.g.mkdp_command_for_global = 1
            vim.g.mkdp_echo_preview_url = 1

            -- Reuse the existing preview tab/page instead of creating a new one
            vim.g.mkdp_combine_preview = 1

            -- Lock the port and IP so the browser points to the exact same URL every time
            vim.g.mkdp_port = "8595"
            vim.g.mkdp_open_to_the_world = 0

            -- Automatically opens the browser preview whenever you enter a markdown buffer
            vim.g.mkdp_auto_start = 0

            -- Automatically close the preview tab/window when switching away from the buffer
            vim.g.mkdp_auto_close = 0
        end,
        config = function()
            local readme_group = vim.api.nvim_create_augroup("ReadmeAutoPreview", { clear = true })

            local readme_patterns = {
                "README.md",
                "readme.md",
                "README",
                "readme",
                "*.README.md",
            }

            -- Open preview when entering a README buffer
            vim.api.nvim_create_autocmd({ "BufEnter" }, {
                group = readme_group,
                pattern = readme_patterns,
                callback = function()
                    if vim.bo.buftype == "" then
                        vim.cmd("MarkdownPreview")
                    end
                end
            })

            -- Stop preview only when completely unloading/deleting the README buffer
            -- (Using BufDelete/BufUnload prevents closing when briefly switching to markdown.lua)
            vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload" }, {
                group = readme_group,
                pattern = readme_patterns,
                callback = function()
                    vim.cmd("MarkdownPreviewStop")
                end,
            })
        end,
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown: Toggle Preview" },
        },
    },
    -- Buffer Styling
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = { "markdown" },
        opts = {
            heading = {
                enabled = true,
                sign = false,
                position = "inline",
                width = "full",
                icons = { " ", " ", " ", " ", " ", " " },
            },
        },
    },
    -- Document Outline / TOC Sidebar
    {
        {
            "hedyhli/outline.nvim",
            cmd = { "Outline", "OutlineOpen" },
            keys = {
                { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle Document Outline" },
            },
            opts = {},
        },
    }
}
