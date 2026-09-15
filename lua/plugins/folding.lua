-- lua/plugins/folding.lua

-- In-memory cache for line kinds: buffer_kinds[bufnr][lnum_1indexed] = "struct" | "fn" | ...
local buffer_kinds = {}

local rust_kinds = {
    struct = { icon = "📦", hl = "UfoFoldStruct", badge_hl = "UfoFoldBadgeStruct" },
    enum   = { icon = "🏷️ ", hl = "UfoFoldEnum", badge_hl = "UfoFoldBadgeEnum" },
    union  = { icon = "🔀", hl = "UfoFoldUnion", badge_hl = "UfoFoldBadgeUnion" },
    fn     = { icon = "⚡", hl = "UfoFoldFn", badge_hl = "UfoFoldBadgeFn" },
    impl   = { icon = "⚙️ ", hl = "UfoFoldImpl", badge_hl = "UfoFoldBadgeImpl" },
    trait  = { icon = "📜", hl = "UfoFoldTrait", badge_hl = "UfoFoldBadgeTrait" },
    module = { icon = "📁", hl = "UfoFoldMod", badge_hl = "UfoFoldBadgeMod" },
    macro  = { icon = "🪄", hl = "UfoFoldMacro", badge_hl = "UfoFoldBadgeMacro" },
}

local function setup_fold_highlights()
    local highlights = {
        -- Struct (Wine / Rose)
        UfoFoldStruct      = { fg = "#ea9a97", bg = "#382933", bold = true },
        UfoFoldBadgeStruct = { fg = "#ebbcba", bg = "#382933", italic = true },

        -- Enum (Amber / Gold)
        UfoFoldEnum        = { fg = "#f6c177", bg = "#383129", bold = true },
        UfoFoldBadgeEnum   = { fg = "#f6c177", bg = "#383129", italic = true },

        -- Fn (Teal / Cyan)
        UfoFoldFn          = { fg = "#56b6c2", bg = "#21323b", bold = true },
        UfoFoldBadgeFn     = { fg = "#9ccfd8", bg = "#21323b", italic = true },

        -- Impl (Purple / Iris)
        UfoFoldImpl        = { fg = "#c4a7e7", bg = "#2f273f", bold = true },
        UfoFoldBadgeImpl   = { fg = "#c4a7e7", bg = "#2f273f", italic = true },

        -- Trait (Slate / Foam)
        UfoFoldTrait       = { fg = "#9ccfd8", bg = "#233338", bold = true },
        UfoFoldBadgeTrait  = { fg = "#9ccfd8", bg = "#233338", italic = true },

        -- Module (Crimson / Love)
        UfoFoldMod         = { fg = "#eb6f92", bg = "#3b222c", bold = true },
        UfoFoldBadgeMod    = { fg = "#eb6f92", bg = "#3b222c", italic = true },

        -- Macro (Cocoa / Coral)
        UfoFoldMacro       = { fg = "#ebbcba", bg = "#3b2d35", bold = true },
        UfoFoldBadgeMacro  = { fg = "#ebbcba", bg = "#3b2d35", italic = true },

        -- Union (Lavender)
        UfoFoldUnion       = { fg = "#e0def4", bg = "#2d2a3e", bold = true },
        UfoFoldBadgeUnion  = { fg = "#e0def4", bg = "#2d2a3e", italic = true },

        -- Fallback
        Folded             = { bg = "#242234", fg = "#c4a7e7" },
        UfoFoldBadge       = { fg = "#ebbcba", bg = "#242234", italic = true },

        -- Fold Diagnostics (inherit the same dark strip tones with bright alert text)
        UfoFoldDiagError   = { fg = "#eb6f92", bold = true },
        UfoFoldDiagWarn    = { fg = "#f6c177", bold = true },
        UfoFoldDiagInfo    = { fg = "#9ccfd8" },
        UfoFoldDiagHint    = { fg = "#908caa" },
    }

    for name, hl_opts in pairs(highlights) do
        vim.api.nvim_set_hl(0, name, hl_opts)
    end
end

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
        buffer_kinds[buf] = {}

        for id, node in query:iter_captures(tree:root(), buf, 0, -1) do
            local s_row, _, e_row, _ = node:range()
            if e_row > s_row then
                local kind = query.captures[id]
                -- Store 1-indexed to match fold_virt_text_handler's lnum parameter
                buffer_kinds[buf][s_row + 1] = kind

                table.insert(ranges, {
                    startLine = s_row,
                    endLine = e_row,
                })
            end
        end

        return ranges
    end,
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
    end,
    opts = {
        provider_selector = function(_, filetype)
            if language_providers[filetype] then
                return language_providers[filetype]
            end
            return function()
                return nil
            end
        end,

        fold_virt_text_handler = function(_, lnum, endLnum, width, _)
            local cur_buf = vim.api.nvim_get_current_buf()
            local raw_line = vim.api.nvim_buf_get_lines(cur_buf, lnum - 1, lnum, false)[1] or ""
            local clean_line = raw_line:gsub("^%s*", ""):gsub("%s*{%s*$", "")

            local kinds = buffer_kinds[cur_buf] or {}
            local kind = kinds[lnum]
            local meta = rust_kinds[kind] or { icon = "󰅩", hl = "Folded", badge_hl = "UfoFoldBadge" }

            local lines_count = endLnum - lnum
            local line_badge = string.format(" 󰁂 %d lines", lines_count)

            -- Check for diagnostics within this fold range (0-indexed line numbers)
            local diags = vim.diagnostic.get(cur_buf, {
                lnum = lnum - 1,
            })
            -- Filter to only diagnostics between start and end of fold
            local err_cnt, warn_cnt = 0, 0
            for _, d in ipairs(vim.diagnostic.get(cur_buf)) do
                if d.lnum >= (lnum - 1) and d.lnum < endLnum then
                    if d.severity == vim.diagnostic.severity.ERROR then
                        err_cnt = err_cnt + 1
                    elseif d.severity == vim.diagnostic.severity.WARN then
                        warn_cnt = warn_cnt + 1
                    end
                end
            end

            -- Build the output segments
            local res = {
                { meta.icon .. " ",  meta.hl },
                { clean_line,        meta.hl },
                { " " .. line_badge, meta.badge_hl },
            }

            local diag_text_len = 0
            if err_cnt > 0 then
                local str = string.format("  󰅚 %d", err_cnt)
                -- Dynamically set the diagnostic background to match the row's background
                vim.api.nvim_set_hl(0, "UfoDiagErrRow_" .. kind,
                    { fg = "#eb6f92", bg = vim.api.nvim_get_hl(0, { name = meta.hl }).bg, bold = true })
                table.insert(res, { str, "UfoDiagErrRow_" .. kind })
                diag_text_len = diag_text_len + vim.fn.strdisplaywidth(str)
            end

            if warn_cnt > 0 then
                local str = string.format("  󰀪 %d", warn_cnt)
                vim.api.nvim_set_hl(0, "UfoDiagWarnRow_" .. kind,
                    { fg = "#f6c177", bg = vim.api.nvim_get_hl(0, { name = meta.hl }).bg, bold = true })
                table.insert(res, { str, "UfoDiagWarnRow_" .. kind })
                diag_text_len = diag_text_len + vim.fn.strdisplaywidth(str)
            end

            local text_len = vim.fn.strdisplaywidth(meta.icon .. " " .. clean_line .. line_badge) + diag_text_len
            local fill_width = math.max(0, width - text_len)
            local padding = (" "):rep(fill_width)

            table.insert(res, { padding, meta.hl })
            return res
        end,
    },
    config = function(_, opts)
        setup_fold_highlights()

        -- Reapply highlights if colorscheme changes
        vim.api.nvim_create_autocmd("ColorScheme", {
            callback = setup_fold_highlights,
        })

        local ufo = require("ufo")
        ufo.setup(opts)

        local auto_fold_group = vim.api.nvim_create_augroup("CustomLanguageAutoFold", { clear = true })
        vim.api.nvim_create_autocmd("BufEnter", {
            group = auto_fold_group,
            pattern = "*.rs",
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
