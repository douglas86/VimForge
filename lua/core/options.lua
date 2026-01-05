-- ~/.config/nvim/core/options

-- local variables
local g = vim.g
local key = vim.keymap
local opt = vim.opt
local ls = require("luasnip")

-- settings
opt.number = true -- Show line numbers
opt.mouse = 'a' -- Enable mouse support
opt.ignorecase = true -- Case-insensitive searching
opt.smartcase = true -- ... until you use a capital letter
opt.undofile = true -- Persistent undo (even after closing nvim)
opt.termguicolors = true -- Better color support for modern terminals
opt.scrolloff = 8 -- Kepp 8 lines visible above/below cursor

-- clipboard (wayland optimized)
-- This ensures you can yank/paste to your COSMIC system clipboard
opt.clipboard = 'unnamedplus'

-- tabs and indentation
opt.tabstop = 4 -- Number of spaces a tab represents
opt.shiftwidth = 4 -- Number of spaces for indentation
opt.expandtab = true -- Convert tabs to spaces

-- global settings
g.mapleader = ' ' -- Set Space as your "leader" key
-- Point Neovim to your asdf-managed binaries for faster startup
g.python3_host_prog = vim.fn.expand('$HOME/.asdf/installs/python/3.13.1/bin/python')
g.node_host_prog = vim.fn.expand('$HOME/.asdf/installs/nodejs/25.2.1/bin/neovim-node-host')
-- Disable providers you don't plan to use to speed up startup and clean up healthchecks
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

-- keymapings
key.set('n', '<leader>q', '<cmd>x<cr>', { desc = 'Save and quit current file' })
key.set('n', '<leader>qa', '<cmd>xa<cr>', { desc = 'Save and quit all files' })

ls.config.set_config({
    history = true,
    delete_check_events = "InsertLeave",
    region_check_events = "CursorMoved",
    update_events = "TextChanged,TextChangedI",
})

-- keymapings for nvim-cmp
-- jump forward in snippets
key.set({ "i", "s" }, "<C-f>", function ()
   if ls.locally_jumpable(1) then
        ls.jump(1)
   end
end, { silent = true })
-- jump backwards in snippets
key.set({ "i", "s" }, "<C-b>", function ()
    if ls.jumpable(-1) then
        ls.jump(-1)
    else
        print("LuaSnip: No backward jump points found")
    end
end, { silent = false })
