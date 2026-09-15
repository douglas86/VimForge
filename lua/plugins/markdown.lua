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

            -- Force light thee for the browser preview
            vim.g.mkdp_theme = "light"
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
                callback = function(args)
                    if vim.bo[args.buf].buftype ~= "" then
                        return
                    end

                    -- Mark the buffer to automatically delete itself once it goes off-screen
                    vim.bo[args.buf].bufhidden = "delete"

                    -- Start the preview
                    vim.cmd("MarkdownPreview")

                    -- Attach cleanup to fire as soon as the buffer is unloaded/deleted
                    vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload" }, {
                        buffer = args.buf,
                        once = true,
                        callback = function()
                            vim.cmd("MarkdownPreviewStop")
                        end,
                    })
                end
            })

            -- Clean up if quitting Neovim directly
            vim.api.nvim_create_autocmd("VimLeavePre", {
                group = readme_group,
                callback = function()
                    vim.cmd("silent! MarkdownPreviewStop")
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
    -- Table formatting automatically
    {
        "dhruvasagar/vim-table-mode",
        ft = { "markdown" },
        cmd = { "TableModeToggle", "TableModeEnable", "TableModeDisable" },
        init = function()
            -- Standard Markdown pipe corners
            vim.g.table_mode_corner = "|"

            -- Automatically enable table mode for markdown files
            vim.g.table_mode_always_active = 1
        end,
        config = function()
            local table_group = vim.api.nvim_create_augroup("MarkdownTableAutoMode", { clear = true })

            -- Turn on Table Mode when entering Insert mode in Markdown
            vim.api.nvim_create_autocmd("InsertEnter", {
                group = table_group,
                pattern = { "*.md", "*.markdown" },
                callback = function()
                    if vim.bo.buftype == "" and vim.fn["tablemode#IsActive"]() == 0 then
                        vim.cmd("silent! TableModeEnable")
                    end
                end
            })

            -- Turn off Table Mode when returning to Normal mode
            vim.api.nvim_create_autocmd("InsertLeave", {
                group = table_group,
                pattern = { "*.md", "*.markdown" },
                callback = function()
                    if vim.bo.buftype == "" and vim.fn["tablemode#IsActive"]() == 1 then
                        vim.cmd("silent! TableModeDisable")
                    end
                end,
            })
        end
    },
    -- Bulleted lists, checkboxes, numbered lists and handled indentation
    {
        "bullets-vim/bullets.vim",
        ft = { "markdown" },
        init = function()
            -- Enable strictly for markdown
            vim.g.bullets_enabled_file_types = { "markdown" }

            -- Automatically renumber ordered lists when items are added, deleted or indented
            vim.g.bullets_renumber_on_change = 1

            --Enable nested/heirarchical checkboxes
            vim.g.bullets_nested_checkboxes = 1

            -- Style of unordered bullet characters across nested levels
            vim.g.bullets_outline_levels = { "std-" }
        end
    },
    -- Paste Images from Clipboard
    {
        "HakonHarnes/img-clip.nvim",
        cmd = { "PasteImage" },
        keys = {
            { "<leader>ip", "<cmd>PasteImage<cr>", desc = "Markdown: Paste to Clipboard" }
        },
        opts = {
            default = {
                -- Subfolder relative to current buffer where images are saved
                prompt_for_file_name = true,
                file_name = "%Y-%m-%d-%H-%M-%S",
                -- Use relative paths so GitHub/GitLab render them cleanly
                use_absolute_path = false,
                relative_to_current_file = true,
            },
            filetypes = {
                markdown = {
                    -- Dynamically target assets/readme if editing a README file,
                    -- otherwise fall back to Standard assets/
                    dir_path = function()
                        local filename = vim.fs.basename(vim.api.nvim_buf_get_name(0)):lower()
                        if filename:match("^readme") then
                            return "assets/readme"
                        end
                        return "assets"
                    end,
                    -- Standard GitHub Markdwon syntax: ![caption](path/to/image.png)
                    template = "![$CURSOR]($FILE_PATH)",
                    url_encode_path = true,
                }
            }
        }
    },
    -- Visual Mode Link & formatting helpers
    {
        "antonk52/markdowny.nvim",
        ft = { "markdown" },
        config = function()
            require("markdowny").setup()
        end,
    },
}
