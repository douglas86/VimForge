-- Load core files
require('cors.mappings').setup()
require('cors.settings')

-- auto start coq plugin on vim start
vim.g.coq_settings = { auto_start = true }

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
	-- Example plugins
	{ "nvim-lua/plenary.nvim" },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufRead", "BufNewFile" },
        config = function()
            require("nvim-treesitter.configs").setup({
                modules = {}, -- Added an empty table to satisfy the Lua Language Server
                ensure_installed = { "lua", "javascript", "typescript", "python" },
                sync_install = false, -- Install parsers synchronously
                auto_install = true, -- Automatically install missing installing
                ignore_install = {},
                highlight = { enable = true }, -- Enable syntax highlighting
                indent = { enable = true }, -- Enable Tree-Sitter-based indentation
                incremental_selection = { enable = true },
				fold = { enable = true }
            })
        end,
    },
	{
        "nvim-telescope/telescope.nvim",
        dependencies = { 'nvim-lua/plenary.nvim' },
        event = 'BufWinEnter',
        config = function()
            require("telescope").setup({
                ensure_installed = { "lua", "javascript", "typescript", "python" },
                highlight = { enable = true },
                indent = { enable = true }, -- Enable Tree-Sitter-based indentation
                defaults = {
                    file_ignore_patterns = { "%.png$", "%.jpg$", "%.jpeg$", "%.gifs", "%.bmp$", "%.svg$", "%.webp" },
                },
            })
        end,
    },
	-- Auto Saving
	{
		"pocco81/auto-save.nvim",
		config = function()
			require("auto-save").setup{
				enabled = true,
				execution_message = {
					message = function()
						return "AutoSaved at " .. vim.fn.strftime("%H:%M:%S")
					end,
				},
				events = {"InsertLeave", "TextChanged"},
				conditions = {
					exits = true,
					filetype_is_not = {}, -- disable for certain filetypes
					modifiable = true,
				},
				write_all_buffers = false, -- only write the current buffer
			}
		end
	},
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                default = true,
            })
        end
    },
    -- File Explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("neo-tree").setup({
                log_level = "debug",
                filesystem = {
                    follow_current_file = true, -- Automatically focus on the current file
                    hijack_netrw = true, -- Replace the default netrw file explorer
                    use_libuv_file_watcher = true, -- Watch for changes using libuv (fast and efficient)
                    filtered_items = {
                        hide_dotfiles = true, -- Hide dotfiles to reduce clutter
                        hide_gitignored = true, -- Hide files ignored by Git
                        hide_by_name = { -- Hide specific files or directories
                            "node_modules",
                            ".git",
                            ".DS_Store",
                        },
                    },
                },
                git_status = {
                    window = {
                        position = "float", -- use a floating window for Git status
                    },
                },
                diagnostics = {
                    symbols = {
                        hint = "", -- Hint symbol (Nerd Font)
                        info = "", -- Info symbol (Nerd Font)
                        warn = "", -- Warning symbol (Nerd Font)
                        error = "", -- Error symbol (Nerd Font)
                    },
                },
                default_component_configs = {
                    icon = {
                      folder_closed = "",
                      folder_open = "",
                      folder_empty = "",
                      default = "",
                    },
                },
                event_handlers = {
                    {
                        event = "file_opened",
                        handler = function()
                            -- Automatically close Neo-tree when a file is opened
                            require("neo-tree.command").execute({ action = "close" })
                        end,
                    },
                },
            })
        end,
    },
    -- git itegration
    {
        "kdheepak/lazygit.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
    -- completion engine
    {
        "ms-jpq/coq_nvim",
        branch = "coq",
        build = ":COQdeps",
        config = function()
            vim.g.coq_settings = {
                auto_start = true, -- Auto start without additional messages
            }
        end,
    },
    -- lua support
    {
        "neovim/nvim-lspconfig",
        config = function()

            local lspconfig = require('lspconfig')

            -- Example: Setting up an LSP for Python (pyright)
            lspconfig.pyright.setup({})

            -- Diagnostics settings (optional)
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                update_in_insert = false,
            })

            -- Enable diagnosics in the gutter
            vim.fn.sign_define('DiagnosticSignError', {text="", texthl='DiagnosticSignError'})
            vim.fn.sign_define('DiagnosticSignWarn', {text="", texthl='DiagnosticSignWarn'})
            vim.fn.sign_define('DiagnosticSignInfo', {text="", texthl='DiagnosticSignInfo'})
            vim.fn.sign_define('DiagnosticSignHint', {text="", texthl='DiagnosticSignHint'})

            require("lspconfig").lua_ls.setup({
                capabilities = require("coq").lsp_ensure_capabilities(),
                cmd = {"lua-language-server"},
                settings = {
                    Lua = {
                        runtime = {
                            version = "LuaJIT", -- Neovim uses LuaJIT
                            path = vim.split(package.path, ";"),
                        },
                        diagnostics = {
                            globals = { "vim" }, -- Recognize Neovim's vim global
                        },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })
        end,
    },
    {
        "folke/neodev.nvim",
        config = function ()
            require("neodev").setup()
        end,
    },
    -- autopairs
    {
        "windwp/nvim-autopairs",
        dependencies = { "nvim-treesitter/nvim-treesitter"},
        event = "InsertEnter", -- Load only when entering Insert mode
        config = function()
            local Rule = require("nvim-autopairs.rule")

            require("nvim-autopairs").setup({
                check_ts = true, -- Enable Tree-sitter integration for better context awareness
                map_cr = true, -- Map <CR> to correctly handle pairs
                fast_wrap = {},
            })

            require("nvim-autopairs").add_rules({
                Rule("[", "]")
            })
        end,
    },
    -- statusline - lualine
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup({
                options = {
                    theme = 'gruvbox',
                },
                sections = {
                    lualine_a = {'mode'},
                    lualine_b = {'branch'},
                    lualine_c = {
                        {'filename'},
                        {
                            'diagnostics',
                            sources = {'nvim_diagnostic'},
                            sections = {'error', 'warn', 'info', 'hint'},
                            symbols = {error = " ", warn = " ", info = " ", hint = " "},
                            colored = true,
                            update_in_insert = false,
                        },
                    },
                    lualine_x = {'encoding',{'fileformat', icons_enabled = true}, 'filetype'},
                    lualine_y = {'progress'},
                    lualine_z = {'location'},
                },
            })
        end
    }
})

-- keybindings for plugins
require("cors.mappings").keybindings()
-- auto commands
require('cors.autocommands')
