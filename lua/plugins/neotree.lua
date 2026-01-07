return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    cmd = "Neotree", -- Lazy load on command
    keys = {
        { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },
    },
    opts = {
        close_if_last_window = true, -- close Neotree if it's the last window open
        filesystem = {
            follow_current_file = {
                enabled = true, -- Focus current file when opening the tree
            },
            use_libuv_file_watcher = true, -- Automatically refresh on file change
        },
        window = {
            position = "float", -- floating window when open
            width = 50,
            mapping_options = {
                noremap = true,
                nowait = true,
            },
            mappings = {
                ["<cr>"] = "open_with_window_picker", -- open file and closes float
                ["l"] = "open_with_window_picker", -- keybinding to open file
            },
        },
        event_handlers = {
            {
                event = "file_opened",
                handler = function ()
                    -- Automatically close the floating window after opening a file
                    require("neo-tree.command").execute({ action = "close" })
                end
            }
        }
    }
}
