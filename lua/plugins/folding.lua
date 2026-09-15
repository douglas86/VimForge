-- lua/plugins/folding.lua
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
            if filetype == "rust" then
                return function(buf)
                    local ok, parser = pcall(vim.treesitter.get_parser, buf, "rust")
                    if not ok or not parser then
                        vim.notify("Provider: parser failed", vim.log.levels.WARN)
                        return {}
                    end

                    local tree = parser:parse()[1]
                    if not tree then
                        vim.notify("Provider: empty tree", vim.log.levels.WARN)
                        return {}
                    end

                    local ok_q, query = pcall(vim.treesitter.query.parse, "rust", "(struct_item) @struct")
                    if not ok_q or not query then
                        vim.notify("Provider: query failed", vim.log.levels.ERROR)
                        return {}
                    end

                    -- Target both structs and enums
                    local query_str = [[
                        (struct_item) @struct
                        (enum_item) @enum
                        (function_item) @fn
                        (impl_item) @impl
                        (trait_item) @trait
                        (mod_item) @module
                        (macro_definition) @macro
                        (union_item) @union
                    ]]
                    ok_q, query = pcall(vim.treesitter.query.parse, "rust", query_str)
                    if not ok_q or not query then return {} end

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

                    vim.notify("Provider generated " .. #ranges .. " struct fold ranges", vim.log.levels.INFO)
                    return ranges
                end
            end
            return function()
                return nil
            end
        end,
    },
    config = function(_, opts)
        local ufo = require("ufo")
        ufo.setup(opts)

        local rust_fold_group = vim.api.nvim_create_augroup("RustStructFoldOnly", { clear = true })
        vim.api.nvim_create_autocmd("BufEnter", {
            group = rust_fold_group,
            pattern = "*.rs",
            callback = function(args)
                vim.defer_fn(function()
                    if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].filetype == "rust" then
                        vim.notify("BufEnter: attempting closeAllFolds()", vim.log.levels.INFO)
                        vim.api.nvim_buf_call(args.buf, function()
                            ufo.closeAllFolds()
                        end)
                    end
                end, 150)
            end,
        })
    end,
    keys = {
        { "zR", function() require("ufo").openAllFolds() end,  desc = "Open all folds" },
        { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
        { "za", "za",                                          desc = "Toggle fold under cursor" },
    },
}
