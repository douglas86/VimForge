-- ~/.config/nvim/lua/core/autocommands.lua


-- local variables
local opt = vim.opt
-- local timer = nil
local auto = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup

opt.updatetime = 500 -- Set the "hold" to 500ms

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
