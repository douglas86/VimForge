-- ~/.config/nvim/core/options

-- local variables
local key = vim.keymap
local ls = require("luasnip")

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
