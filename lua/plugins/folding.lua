-- lua/plugins/folding.lua
-- lua/plugins/folding.lua

-- Language-specific fold extractors
local language_providers = {
    rust = function(buf)
        local ok, parser = pcall(vim.treesitter.get_parser, buf, "rust")
        if not ok or not parser then return {} end

        local tree = parser:parse()[1]
        if not tree then return {} end

        local query_str = [[
            (struct_item) @struct
            (enum_item) @enum
            (union_item) @union
            (function_item) @fn
            (impl_item) @impl
            (trait_item) @trait
            (mod_item) @module
            (macro_definition) @macro
        ]]

        local ok_query, query = pcall(vim.treesitter.query.parse, "rust", query_str)
        if not ok_query or not query then return {} end

        local ranges = {}
        for _, node in query:iter_captures(tree:root(), buf, 0, -1) do
            local s_row, _, e_row, _ = node:range()
            if e_row > s_row then
                table.insert(ranges, {
                    startLine = s_row,
                    endLine = e_row,
                })
            end
        end

        return ranges
    end,

    -- Add future languages here:
    -- toml = function(buf) ... return ranges end,
    -- python = function(buf) ... return ranges end,
}

return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    init = function()
        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 99
        vim.o.foldlevelstart = 99
        vim.o.foldenable = true

        vim.api.nvim_set_hl(0, "Folded", { bg = "#242234", fg = "#c4a7e7", bold = true })
        vim.api.nvim_set_hl(0, "UfoFoldBadge", { bg = "#393552", fg = "#ebbcba" })
    end,
    opts = {
        provider_selector = function(_, filetype)
            -- If we have a custom extractor for this filetype, use it
            if language_providers[filetype] then
                return language_providers[filetype]
            end

            -- Default fallback for other languages (or nil to ignore)
            return function()
                return nil
            end
        end,
    },
    config = function(_, opts)
        local ufo = require("ufo")
        ufo.setup(opts)

        -- Auto-close folds for supported languages on buffer open
        local auto_fold_group = vim.api.nvim_create_augroup("CustomLanguageAutoFold", { clear = true })
        vim.api.nvim_create_autocmd("BufEnter", {
            group = auto_fold_group,
            callback = function(args)
                local ft = vim.bo[args.buf].filetype
                if language_providers[ft] then
                    vim.defer_fn(function()
                        if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].filetype == ft then
                            vim.api.nvim_buf_call(args.buf, function()
                                ufo.closeAllFolds()
                            end)
                        end
                    end, 150)
                end
            end,
        })
    end,
    keys = {
        { "zR", function() require("ufo").openAllFolds() end,  desc = "Open all folds" },
        { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
        { "za", "za",                                          desc = "Toggle fold under cursor" },
    },
}
