-- ~/.config/nvim/core/options

-- local variables
local g = vim.g
local key = vim.keymap
local opt = vim.opt

-- settings
opt.number = true -- show line numbers
opt.mouse = 'a' -- Enable mouse support
opt.ignorecase = true -- Case-insensitive searching
opt.smartcase = true -- ... until you use a capital letter
opt.undofile = true -- Persistent undo (even after closing nvim)
opt.termguicolors = true -- Better color support for modern terminals
opt.scrolloff = 8 -- Keep 8 lines visible above/below cursor
opt.clipboard = 'unnamedplus' -- this ensures you can yank/paste to your COSMIC system clipboard
opt.tabstop = 4 -- Number of spaces a tab represents
opt.shiftwidth = 4 -- Number of spaces for indentation
opt.expandtab = true -- Convert tabs to spaces

-- global settings
g.mapleader = ' '
-- Point Neovim to your asdf-managed binaries for faster startup
g.python3_host_prog = vim.fn.expand('$HOME/.asdf/installs/python/3.13.1/bin/python')
g.node_host_prog = vim.fn.expand('$HOME/.asdf/installs/nodejs/25.2.1/bin/neovim-node-host')
-- Disable providers you don't plan to use to speed up startup and clean up healthchecks
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0

-- keymappings
-- File save & quit
key.set('n', '<leader>w', '<cmd>w<cr>', { desc = 'Save file' })
key.set('n', '<leader>q', '<cmd>q<cr>', { desc = 'Quit file' })
key.set('n', '<leader>x', '<cmd>x<cr>', { desc = 'Save and quit file' })
key.set('n', '<leader>qa', '<cmd>xa<cr>', { desc = 'Save and quit all files' })

-- Quick pane/window navigation
key.set('n', '<C-h>', '<C-w>h', { desc = 'Move focus to left pane' })
key.set('n', '<C-j>', '<C-w>j', { desc = 'Move focus to the lower pane' })
key.set('n', '<C-k>', '<C-w>k', { desc = 'Move focus to the upper pane' })
key.set('n', '<C-l>', '<C-w>l', { desc = 'Move focus to right pane' })
