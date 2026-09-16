-- lua/plugins/buffers.lua

return {
    "axkirillov/hbac.nvim",
    event = "VeryLazy",
    opts = {
        autoclose = true,
        threshold = 10, -- Maximum hidden unpinned buffers
        close_command = function(bufnr)
            vim.api.nvim_buf_delete(bufnr, { unload = false })
        end,
        close_buffers_with_windows = false,
    },
}
