-- local variables for file
local api = vim.api

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
    callback = function()
        -- Get the current buffer's filetype and name
        local filetype = vim.bo.filetype
        local bufname = api.nvim_buf_get_name(0)

        -- skip buffers with no name or specific filetypes like TelescopePrompt 
        if filetype == "TelescopePrompt" or filetype == "nofile" or bufname == "" then
            return
        end

        vim.cmd("silent! mkview")
    end,
})

-- Restore fold on buffer enter
api.nvim_create_autocmd({ "BufWinEnter" }, {
	pattern = "*",
	command = "silent! loadview",
})

-- Close all hidden buffers on BufWinLeave 
api.nvim_create_autocmd({ "BufWinLeave" }, {
    pattern = "*",
    callback = function()
        -- Get the current buffer's filetype
        local filetype = vim.bo.filetype

        -- Skip buffers with filetype TelescopePrompt or no name
        if filetype == "TelescopePrompt" or api.nvim_buf_get_name(0) == "" then
            return
        end

        -- Iterate over all buffers
        for _, buf in ipairs(api.nvim_list_bufs()) do
            -- check if the buffer is loaded and hidden
            if api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and #vim.fn.win_findbuf(buf) == 0 then
                -- Deletes the buffer
                api.nvim_buf_delete(buf, { force = true })
            end
        end
    end,
})

-- Show diagnostic window as a popup
api.nvim_create_autocmd("CursorMoved", {
    pattern = "*",
    callback = function()
        local current_pos = vim.api.nvim_win_get_cursor(0) -- Get the current cursor position
        local line = current_pos[1] - 1 -- Convert 1-based line number to 0-based
        local diagnostic = vim.diagnostic.get(0, { lnum = line }) -- Get diagnostics for the current line

        -- Show diagnostics if they exist
        if #diagnostic > 0 then
            vim.diagnostic.open_float(nil, { focus = false, scope = "line" })
        end
    end,
})
