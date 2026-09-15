-- rust.lua

return {
    -- Rust LSP & Tooling (Wraps rust-analyzer)
    {
        "mrcjkb/rustaceanvim",
        lazy = false, -- Plugin handles its own lazy-loading via filetype
        init = function()
            vim.g.rustaceanvim = {
                server = {
                    on_attach = function(_, bufnr)
                        -- Buffer local keymaps for Rustacean commands
                        local map = function(mode, lhs, rhs, desc)
                            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = "Rust: " .. desc })
                        end

                        map("n", "<leader>ca", "<cmd>RustLsp codeAction<cr>", "Code Action")
                        map("n", "<leader>rd", "<cmd>RustLsp debuggables<cr>", "Debuggables")
                        map("n", "<leader>rr", "<cmd>RustLsp runnables<cr>", "Runnables")
                        map("n", "K", "<cmd>RustLsp hover actions<cr>", "Hover Actions")
                        map("n", "<leader>em", "<cmd>RustLsp expandMacro<cr>", "Expand Macro")
                    end,
                    default_settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                                buildScripts = {
                                    enable = true,
                                },
                            },
                            checkOnSave = true,
                            check = {
                                command = "clippy", -- Use clippy for linting on save
                                extraArgs = { "--no-deps" },
                            },
                            procMacro = {
                                enable = true,
                                ignored = {
                                    ["async-trait"] = { "async_trait" },
                                    ["napi-derive"] = { "napi" },
                                    ["async-recursion"] = { "async_recursion" },
                                },
                            },
                            inlayHints = {
                                lifetimeElisionHints = {
                                    enable = "skip_trivial",
                                    useParameterNames = true,
                                },
                                closureReturnTypeHints = {
                                    enable = "always",
                                }
                            }
                        }
                    }
                }
            }
        end
    },

    --Cargo.toml Dependency Management & Version Checks
    {
        "saecki/crates.nvim",
        event = { "BufRead Cargo.toml" },
        opts = {
            completion = {
                cmp = {
                    enabled = true,
                },
            },
            null_ls = {
                enabled = false,
            }
        },
        config = function(_, opts)
            local crates = require("crates")
            crates.setup(opts)

            local function set_crates_keymaps(bufnr)
                local map = function(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = "Crates: " .. desc })
                end

                map("<leader>ct", crates.toggle, "Toggle virtual text")
                map("<leader>cr", crates.reload, "Reload crate info")
                map("<leader>cu", crates.update_crate, "Update crate to latest")
                map("<leader>cU", crates.upgrade_crate, "Upgrade crate (major)")
                map("<leader>ch", crates.show_popup, "Show crate details")
                map("<leader>cd", crates.open_documentation, "Open docs.rs")
            end

            -- Attach keymaps to the buffer that just loaded crates.nvim
            if vim.fs.basename(vim.api.nvim_buf_get_name(0)) == "Cargo.toml" then
                set_crates_keymaps(vim.api.nvim_get_current_buf())
            end

            -- Ensure future visits or other Cargo.toml files in a workspace also get mapped
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "Cargo.toml",
                callback = function(args)
                    set_crates_keymaps(args.buf)
                end,
            })
        end
    }
}
