-- Setup lazy.nvim
require("lazy").setup({
    -- 1. Colorscheme
    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
    -- 3. Syntax Highlighting (Treesitter)
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    -- 4. Auto Pairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true
    },
    -- 5. visual file explorer
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons", -- Requires a Nerd Font for icons
        },
        config = function ()
            require("neo-tree").setup({
                window = {
                    position = "float",
                    popup_border_style = "rounded", -- Makes it look modern
                    mappings = {
                        ["<space>"] = "none", -- Disable space so it doesn't conflict with your leader
                    },
                },
                filesystem = {
                    filtered_items = {
                        visible = true, -- Show dotfiles
                    }
                },
                event_handlers = {
                    {
                        event = "file_opened",
                        handler = function()
                            -- This forces the float to close immediately upon selecting a file
                            require("neo-tree.command").execute({ action = "close" })
                        end,
                    }
                }
            })
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            { "williamboman/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
        opts = {
            -- Servers to install automatically
            ensure_installed = { "lua_ls", "pyright", "ts_ls" },

            automatic_enable = true,
        },
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function() vim.fn["mkdp#util#install"]() end,
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
        ft = { "markdown" },
        config = function()
            require("render-markdown").setup({})
        end,
    },
    {
        "folke/lazydev.nvim",
        ft = 'lua', -- only load on lua files
        opts = {
            library = {
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" }},
            },
        },
    },
    {
      "kdheepak/lazygit.nvim",
      cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
      },
      -- optional for floating window border decoration
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      keys = {
        { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      },
    },
    {
      "Pocco81/auto-save.nvim",
      config = function()
        require("auto-save").setup({
          enabled = true,
          execution_message = {
            message = function() return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S")) end,
            dim = 0.18,
            cleaning_interval = 1250,
          },
          trigger_events = {"InsertLeave", "TextChanged"},
          -- Do not save for these filetypes
          condition = function(buf)
            local fn = vim.fn
            require("auto-save.utils.data")
            if fn.getbufvar(buf, "&filetype") == "gitcommit" then
              return false
            end
            return true
          end,
        })
      end,
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter", -- The plugin only loads when you enter Insert Mode
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                snippet = {
                    expand = function(args)
                      require('luasnip').lsp_expand(args.body)
                    end,
                  },
                  -- Floating window styling
                  window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                  },
                  mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept with Enter
                    ['<Tab>'] = cmp.mapping.select_next_item(),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
                  }),
                  sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                  }, {
                    { name = 'buffer' },
                  })
                            })
        end,
    },
})

