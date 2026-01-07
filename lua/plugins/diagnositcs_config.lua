function M()
    local signs = { Error = "●", Warn = "●", Hint = "●", Info = "●" }

    for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    return {
        "rachartier/tiny-inline-diagnostic.nvim",
        event = "VeryLazy",
        priority = 1000,
        config = function ()
        	require("tiny-inline-diagnostic").setup({
                preset = "powerline",
                set_arrow_from_diag_color = true,
                signs = {
                        diag = "●",          -- This sets the main diagnostic icon to a circle
                        arrow = "  ",       -- Optional: arrow pointing to the error
                        up_arrow = "  ",    -- Optional: arrow for multi-line
                        vertical = " │",     -- Optional: vertical line for multi-line
                        vertical_end = " └", -- Optional: end of vertical line
                },
                options = {
                    add_messages = {
                        display_count = true,
                    },
                    show_source = {
                        enabled = true,
                    },
                    multilines = {
                        enabled = true,
                    }
                }
            })

            vim.diagnostic.open_float = require("tiny-inline-diagnostic.override").open_float
            vim.diagnostic.config({ float = false, virtual_text = false, update_in_insert = false, })
        end,
    }
end

return M()
