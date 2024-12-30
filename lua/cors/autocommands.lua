-- local variables for file
local api = vim.api
-- local opt = vim.opt

-- autocommand group for filetype-specific settings
api.nvim_create_augroup("MyFileTypeSettings", { clear = true })

-- Set tab width to 2 for JavaScript/TypeScript files
api.nvim_create_autocmd("FileType", {
    group = "MyFileTypeSettings",
    pattern = "javascript,javascriptreact,typescript,typescriptreact",
    callback = function()
        vim.bo.tabstop = 2
        vim.bo.shiftwidth = 2
        vim.bo.expandtab = true
    end,
})

-- Update autoindent key
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function ()
        vim.bo.indentkeys = "0{,0},0],:,0#,!^F,o,o,e,0=end,0=until"
    end,
})

-- Save fold on buffer leave
api.nvim_create_autocmd({ "BufWinLeave" }, {
	pattern = "*",
	command = "mkview",
})
-- Restore fold on buffer enter
api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = "*",
	command = "silent! loadview",
})
