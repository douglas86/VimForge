-- set local variables for file
local opt = vim.opt

-- Enable line numbers
opt.number = true

-- auto indent
opt.smartindent = true
opt.autoindent = true
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4

-- center the cursor dynamically
vim.o.scrolloff = 10
vim.o.wrap = false
