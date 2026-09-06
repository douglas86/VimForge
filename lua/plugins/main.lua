-- Setup lazy.nvim
return {
    -- 1. Colorscheme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function ()
            vim.cmd.colorscheme "catppuccin"
        end
    },
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
    -- version control
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
        { "<C-g>", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      },
    },
    {
        "lewis6991/gitsigns.nvim",
          event = { "BufReadPre", "BufNewFile" }, -- Load only when a file is opened
          opts = {
            signs = {
              add          = { text = "┃" },
              change       = { text = "┃" },
              delete       = { text = "_" },
              topdelete    = { text = "‾" },
              changedelete = { text = "~" },
              untracked    = { text = "┆" },
            },
            on_attach = function(bufnr)
              local gitsigns = require('gitsigns')
              local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
              end
              -- Navigation
              map('n', ']c', function()
                if vim.wo.diff then return ']c' end
                vim.schedule(function() gitsigns.nav_hunk('next') end)
                return '<Ignore>'
              end, { expr = true, desc = "Next Git hunk" })
              map('n', '[c', function()
                if vim.wo.diff then return '[c' end
                vim.schedule(function() gitsigns.nav_hunk('prev') end)
                return '<Ignore>'
              end, { expr = true, desc = "Prev Git hunk" })
              -- Actions (Preview Hunk)
              map('n', '<leader>hp', gitsigns.preview_hunk, { desc = "Preview Git hunk" })
              map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end, { desc = "Git blame line" })
            end
          }
    },
    {
    -- 1. Diffview: Project-wide diffs and file history
      {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory" },
        keys = {
          { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
          { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
        },
        opts = {},
      },
      -- 2. Git-conflict: Smart merge conflict markers
      {
        "akinsho/git-conflict.nvim",
        version = "*",
        config = function()
          require("git-conflict").setup({
            default_mappings = true, -- Sets up co, ct, cb, c0 (see below)
            disable_diagnostics = true, -- Hides LSP errors during conflicts
            list_opener = "copen",
            highlights = {
                incoming = 'DiffAdd',
                current = 'DiffText',
            },
            debug = false,
          })
        end,
      },
    },
    -- auto saving
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

            -- load snippets configuratation file
            require("luasnip.loaders.from_lua").lazy_load({
                paths = vim.fn.stdpath("config") .. "/lua/snippets",
            })

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
    -- Todo Comments
    {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
     signs = true, -- show icons in the signs column
     sign_priority = 8,
     keywords = {
       FIX = {
         icon = " ", -- icon used for the sign, and in search results
         color = "error", -- can be a hex color, or a named color (error, warning, info, hint, default, test)
         alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
       },
       TODO = { icon = " ", color = "info" },
       HACK = { icon = " ", color = "warning" },
       WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
       PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
       NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
       TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
     },
     gui_style = {
       fg = "NONE",
       bg = "BOLD",
     },
     colors = {
       error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
       warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
       info = { "DiagnosticInfo", "#2563EB" },
       hint = { "DiagnosticHint", "#10B981" },
       default = { "Identifier", "#7C3AED" },
       test = { "Identifier", "#FF006E" },
    },
    config = function (_, opts)
        require("todo-comments").setup(opts)
    end
  },
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find Todos (Telescope)" },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todos (Trouble)" },
  },
},
{
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {},
    keys = {
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Diagnostics (Trouble)",
        },
        {
            "<leader>xt",
            "<cmd>Trouble todo toggle<cr>",
            desc = "Todo list (Trouble)",
        }
    }
}

}

