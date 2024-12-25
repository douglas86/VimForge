-- Load core files
require('cors.mappings').setup()
require('cors.settings')
require('cors.autocommands')

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

--      ●       

-- Load plugins
require("lazy").setup({
	-- Example plugins
	{ "nvim-lua/plenary.nvim" },
	{ "nvim-telescope/telescope.nvim" },
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
                        handler = function(file_path)
                            -- Automatically close Neo-tree when a file is opened
                            require("neo-tree.command").execute({ action = "close" })
                        end,
                    },
                },
            })
        end,
    },
})

-- keybindings for plugins
require("cors.mappings").keybindings()
