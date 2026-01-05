-- ~/.config/nvim/lua/core/autocommands.lua

-- local variables
local opt = vim.opt
-- local timer = nil
local auto = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup

opt.updatetime = 500 -- Set the "hold" to 500ms

-- Create an autocmd to open the diagnostic float
auto("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, {
            focusable = false,
            close_events = { "CursorMoved", "CursorMovedI", "BufLeave", "InsertEnter" },
            source = 'always', -- Shows if the error is from 'lua_ls', 'pyright', etc.
            prefix = ' ',
            scope = 'cursor',
        })
    end,
})

-- Create a group to manage these autocommands
-- local diagnostic_updates = group("DiagnosticUpdates", { clear = true })

-- local function debounced_diagnostics_update()
--     -- Cancel any existing timer if a new event comes in
--     if timer then
--         if not timer:is_closing() then
--             timer:stop()
--             timer:close()
--         end
-- 
--         timer = nil
--     end
-- 
--     -- Create a new timer that waits 200ms before running
--     timer = vim.uv.new_timer()
--     if timer then
--         timer:start(200, 0, vim.schedule_wrap(function()
--             -- Background updates
--             vim.diagnostic.setloclist({ open = false })
--             vim.diagnostic.setqflist({ open = false })
--             -- Refresh the UI
--             require('lualine').refresh()
--             -- Clean up after execution
--             if timer and not timer:is_closing() then
--                 timer:close()
--             end
--             timer = nil
--         end))
--     end
-- end
-- 
-- local function update_global_diagnostics()
--     -- Get all diagnostic from the workspace (not just open buffer)
--     vim.diagnostic.get()
-- 
--     -- if your LSP supports workspace scanning, this will fill the Quickfix list
--     -- 'open = false' keep the UI clean
-- 
--     vim.diagnostic.setqflist({
--         open = false,
--         title = "Project Diagnostics",
--         severity = { min = vim.diagnostic.severity.HINT }
--     })
-- 
--     -- Refresh Lualine to show the new count immediately
--     require('lualine').refresh()
-- end
-- 
-- local project_diag_grp = group("ProjectDiagnostics", { clear = true })
-- 
-- auto("LspAttach", {
--     group = project_diag_grp,
--     callback = function()
--         -- Once the LSP attaches, wait a moment for it to index, then scan
--         vim.defer_fn(function()
--             update_global_diagnostics()
--         end, 1000)
--     end,
-- })
-- 
-- -- Update local and global diagnostic variables stored on status line
-- auto("DiagnosticChanged", {
--     group = diagnostic_updates,
--     callback = debounced_diagnostics_update,
-- })

-- autogroup for neo-tree
local neotree_group = group("NeoTreeAutomation", { clear = true })

-- Close Neo-tree if you move focus away from the float
auto("WinLeave", {
    group = neotree_group,
    callback = function()
        if vim.bo.filetype == "neo-tree" then
            vim.schedule(function()
                vim.cmd("Neotree close")
            end)
        end
    end,
})

-- Centre cursor vertically
local centre_group = group("CenterCursor", { clear = true })

auto({ "CursorMoved" }, {
    group = centre_group,
    callback = function()
       if vim.bo.filetype == "neo-tree" or vim.bo.buftype ~= "" then
         return
       end
        vim.cmd("normal! zz")
    end,
})
