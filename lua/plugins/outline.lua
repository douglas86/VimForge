-- outline.lua

return {
    -- Document Outline / TOC Sidebar
    {
        {
            "hedyhli/outline.nvim",
            cmd = { "Outline", "OutlineOpen" },
            keys = {
                { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle Document Outline" },
            },
            opts = {},
        },
    }
}
