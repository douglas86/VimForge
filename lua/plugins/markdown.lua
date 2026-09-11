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

            -- Automatically opens the browser preview whenever you enter a markdown buffer
            vim.g.mkdp_auto_start = 1

            -- Automatically close the preview tab/window when switching away from the buffer
            vim.g.mkdp_auto_close = 1
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
