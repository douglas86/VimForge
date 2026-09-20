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

local toml_kinds = {
    package      = { icon = "📦", hl = "UfoFoldCargoPkg", badge_hl = "UfoFoldBadgeCargoPkg" },
    dependencies = { icon = "🔗", hl = "UfoFoldCargoDeps", badge_hl = "UfoFoldBadgeCargoDeps" },
    features     = { icon = "🎛️ ", hl = "UfoFoldCargoFeat", badge_hl = "UfoFoldBadgeCargoFeat" },
    bin          = { icon = "🚀", hl = "UfoFoldCargoTarget", badge_hl = "UfoFoldBadgeCargoTarget" },
    table        = { icon = "📋", hl = "UfoFoldTomlTable", badge_hl = "UfoFoldBadgeTomlTable" },
}

local lua_kinds = {
    fn    = { icon = "󰊕", hl = "UfoFoldLuaFn", badge_hl = "UfoFoldBadgeLuaFn" },
    table = { icon = "", hl = "UfoFoldLuaTable", badge_hl = "UfoFoldBadgeLuaTable" },
}

local function setup_fold_highlights()
    local highlights = {
        -- Rust Highlight groups
        -- Struct (Wine / Rose)
        UfoFoldStruct           = { fg = "#ea9a97", bg = "#382933", bold = true },
        UfoFoldBadgeStruct      = { fg = "#ebbcba", bg = "#382933", italic = true },
        -- Enum (Amber / Gold)
        UfoFoldEnum             = { fg = "#f6c177", bg = "#383129", bold = true },
        UfoFoldBadgeEnum        = { fg = "#f6c177", bg = "#383129", italic = true },
        -- Fn (Teal / Cyan)
        UfoFoldFn               = { fg = "#56b6c2", bg = "#21323b", bold = true },
        UfoFoldBadgeFn          = { fg = "#9ccfd8", bg = "#21323b", italic = true },
        -- Impl (Purple / Iris)
        UfoFoldImpl             = { fg = "#c4a7e7", bg = "#2f273f", bold = true },
        UfoFoldBadgeImpl        = { fg = "#c4a7e7", bg = "#2f273f", italic = true },
        -- Trait (Slate / Foam)
        UfoFoldTrait            = { fg = "#9ccfd8", bg = "#233338", bold = true },
        UfoFoldBadgeTrait       = { fg = "#9ccfd8", bg = "#233338", italic = true },
        -- Module (Crimson / Love)
        UfoFoldMod              = { fg = "#eb6f92", bg = "#3b222c", bold = true },
        UfoFoldBadgeMod         = { fg = "#eb6f92", bg = "#3b222c", italic = true },
        -- Macro (Cocoa / Coral)
        UfoFoldMacro            = { fg = "#ebbcba", bg = "#3b2d35", bold = true },
        UfoFoldBadgeMacro       = { fg = "#ebbcba", bg = "#3b2d35", italic = true },
        -- Union (Lavender)
        UfoFoldUnion            = { fg = "#e0def4", bg = "#2d2a3e", bold = true },
        UfoFoldBadgeUnion       = { fg = "#e0def4", bg = "#2d2a3e", italic = true },

        -- Specific Cargo Section Highlights
        UfoFoldCargoPkg         = { fg = "#ea9a97", bg = "#382933", bold = true }, -- Rose / Muted Wine
        UfoFoldBadgeCargoPkg    = { fg = "#ea9a97", bg = "#382933", italic = true },

        UfoFoldCargoDeps        = { fg = "#56b6c2", bg = "#21323b", bold = true }, -- Cyan / Deep Teal
        UfoFoldBadgeCargoDeps   = { fg = "#56b6c2", bg = "#21323b", italic = true },

        UfoFoldCargoFeat        = { fg = "#f6c177", bg = "#383129", bold = true }, -- Gold / Dark Amber
        UfoFoldBadgeCargoFeat   = { fg = "#f6c177", bg = "#383129", italic = true },

        UfoFoldCargoTarget      = { fg = "#c4a7e7", bg = "#2f273f", bold = true }, -- Purple / Iris
        UfoFoldBadgeCargoTarget = { fg = "#c4a7e7", bg = "#2f273f", italic = true },

        -- Fallback for generic TOML tables
        UfoFoldTomlTable        = { fg = "#9ccfd8", bg = "#233338", bold = true },
        UfoFoldBadgeTomlTable   = { fg = "#9ccfd8", bg = "#233338", italic = true },

        -- Lua Highlights
        UfoFoldLuaFn            = { fg = "#56b6c2", bg = "#21323b", bold = true }, -- Deep Teal
        UfoFoldBadgeLuaFn       = { fg = "#9ccfd8", bg = "#21323b", italic = true },
        UfoFoldLuaTable         = { fg = "#51a0cf", bg = "#212e3b", bold = true }, -- Lua Blue / Dark Steel
        UfoFoldBadgeLuaTable    = { fg = "#51a0cf", bg = "#212e3b", italic = true },

        -- Fallback
        Folded                  = { bg = "#242234", fg = "#c4a7e7" },
        UfoFoldBadge            = { fg = "#ebbcba", bg = "#242234", italic = true },

        -- Fold Diagnostics (inherit the same dark strip tones with bright alert text)
        UfoFoldDiagError        = { fg = "#eb6f92", bold = true },
        UfoFoldDiagWarn         = { fg = "#f6c177", bold = true },
        UfoFoldDiagInfo         = { fg = "#9ccfd8" },
        UfoFoldDiagHint         = { fg = "#908caa" },
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
    toml = function(buf)
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        local total_lines = #lines
        if total_lines == 0 then return {} end

        local ranges = {}
        buffer_kinds[buf] = {}

        local headers = {}
        for i, line in ipairs(lines) do
            local clean = line:match("^%s*(.-)%s*$")
            local table_array = clean:match("^%[%[(.+)%]%]$")
            local single_table = clean:match("^%[(.+)%]$")

            local name = table_array or single_table
            if name then
                -- Match specific cargo sections
                local kind = "table"
                if name == "package" then
                    kind = "package"
                elseif name:find("dependencies") then
                    -- Catches [dependencies], [dev-dependencies], [build-dependencies]
                    kind = "dependencies"
                elseif name:find("features") then
                    kind = "features"
                elseif name:find("bin") or name:find("lib") or name:find("example") then
                    kind = "bin"
                end

                table.insert(headers, { row = i - 1, kind = kind })
            end
        end

        for idx, h in ipairs(headers) do
            local s_row = h.row
            local next_h = headers[idx + 1]
            local raw_e_row = next_h and (next_h.row - 1) or (total_lines - 1)

            while raw_e_row > s_row and lines[raw_e_row + 1]:match("^%s*$") do
                raw_e_row = raw_e_row - 1
            end

            if raw_e_row > s_row then
                buffer_kinds[buf][s_row + 1] = h.kind
                table.insert(ranges, {
                    startLine = s_row,
                    endLine = raw_e_row,
                })
            end
        end

        return ranges
    end,
    lua = function(buf)
        local ok, parser = pcall(vim.treesitter.get_parser, buf, "lua")
        if not ok or not parser then return {} end

        local tree = parser:parse()[1]
        if not tree then return {} end

        local query_str = [[
            (function_declaration) @fn
            (function_definition) @fn
            (table_constructor) @table
        ]]

        local ok_query, query = pcall(vim.treesitter.query.parse, "lua", query_str)
        if not ok_query or not query then return {} end

        local ranges = {}
        buffer_kinds[buf] = {}

        for id, node in query:iter_captures(tree:root(), buf, 0, -1) do
            local s_row, _, e_row, _ = node:range()
            -- Only fold blocks that span more than 2 lines
            if e_row - s_row > 2 then
                local kind = query.captures[id]
                -- Don't overwrite if an outer node already tagged this line
                if not buffer_kinds[buf][s_row + 1] then
                    buffer_kinds[buf][s_row + 1] = kind
                end

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
            -- 1. Retrieve the stored kind for this line
            local kinds = buffer_kinds[cur_buf] or {}
            local kind = kinds[lnum] or "default"

            local ft = vim.bo[cur_buf].filetype
            local meta_table = rust_kinds
            if ft == "toml" then
                meta_table = toml_kinds
            elseif ft == "lua" then
                meta_table = lua_kinds
            end
            local meta = meta_table[kind] or { icon = "󰅩", hl = "Folded", badge_hl = "UfoFoldBadge" }

            local lines_count = endLnum - lnum
            local line_badge = string.format(" 󰁂 %d lines", lines_count)

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

        -- 1. FOLD ONLY ON INITIAL FILE LOAD
        vim.api.nvim_create_autocmd("BufReadPost", {
            group = auto_fold_group,
            pattern = { "*.rs", "*.toml", "*.lua" },
            callback = function(args)
                -- Only run if not already folded in this buffer session
                if vim.b[args.buf].initial_folded then
                    return
                end
                vim.b[args.buf].initial_folded = true

                local ft = vim.bo[args.buf].filetype
                if language_providers[ft] then
                    vim.defer_fn(function()
                        if vim.api.nvim_buf_is_valid(args.buf) then
                            vim.api.nvim_buf_call(args.buf, function()
                                ufo.closeAllFolds()
                            end)
                        end
                    end, 150)
                end
            end,
        })

        -- 2. CLEAN UP BUFFER STATE ON CLOSE/WIPEOUT
        vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
            group = auto_fold_group,
            callback = function(args)
                buffer_kinds[args.buf] = nil
                vim.b[args.buf].initial_folded = nil
            end,
        })

        -- 3. REFRESH FOLDS ON SAVE
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = auto_fold_group,
            pattern = { "*.rs", "*.toml", "*.lua" },
            callback = function(args)
                require("ufo").getFolds(args.buf, "treesitter")
            end,
        })
    end,
    keys = {
        { "zR", function() require("ufo").openAllFolds() end,  desc = "Open all folds" },
        { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
        { "za", "za",                                          desc = "Toggle fold under cursor" },
        {
            "K",
            function()
                local winid = require("ufo").peekFoldedLinesUnderCursor()
                if not winid then
                    vim.lsp.buf.hover()
                end
            end,
            desc = "Hover documentation or preview fold",
        },
    },
}
