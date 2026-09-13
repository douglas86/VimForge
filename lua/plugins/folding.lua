-- lua/plugins/folding.lua
return {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    init = function()
        vim.o.foldcolumn = "1"
        vim.o.foldlevel = 0
        vim.o.foldlevelstart = 0
        vim.o.foldenable = true
        vim.opt.foldignore = "" -- Prevent Vim from swallowing blank lines into adjacent

        -- Banner highlight styling
        vim.api.nvim_set_hl(0, "Folded", { bg = "#242234", fg = "#c4a7e7", bold = true })
        vim.api.nvim_set_hl(0, "UfoFoldBadge", { bg = "#393552", fg = "#ebbcba" })
    end,
    opts = {
        provider_selector = function(_, filetype, _)
            if filetype == "rust" or filetype == "toml" then
                return { "treesitter", "indent" }
            end
            return { "lsp", "indent" }
        end,

        fold_virt_text_handler = function(_, lnum, endLnum, width, _)
            local ft = vim.bo.filetype
            local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
            local icon = "󰅩"
            local clean_line = line:gsub("^%s*", "")

            if ft == "rust" then
                if line:match("%f[%w]struct%f[%W]") then
                    icon = "📦"
                elseif line:match("%f[%w]enum%f[%W]") then
                    icon = "🏷️ "
                elseif line:match("%f[%w]impl%f[%W]") then
                    icon = "⚙️ "
                elseif line:match("%f[%w]fn%f[%W]") then
                    icon = "⚡"
                end
                clean_line = clean_line:gsub("%s*{%s*$", "")
            elseif ft == "toml" then
                if line:match("%[package%]") then
                    icon = "📦"
                elseif line:match("%[.*dependenc.*%]") then
                    icon = "📚"
                elseif line:match("%[features%]") then
                    icon = "🎛️ "
                elseif line:match("%[.*profile.*%]") or line:match("%[workspace%]") then
                    icon = "⚙️ "
                else
                    icon = "📄"
                end
            end

            local lines_count = endLnum - lnum
            local line_badge = string.format(" 󰁂 %d lines ", lines_count)

            local text_len = vim.fn.strdisplaywidth(icon .. " " .. clean_line .. line_badge)
            local fill_width = math.max(0, width - text_len)
            local padding = (" "):rep(fill_width)

            return {
                { icon .. " ",       "Folded" },
                { clean_line,        "Folded" },
                { " " .. line_badge, "UfoFoldBadge" },
                { padding,           "Folded" },
            }
        end,
    },
    config = function(_, opts)
        local ufo = require("ufo")
        ufo.setup(opts)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "toml", "rust" },
            callback = function()
                -- Give each fold a clean visual break
                vim.opt_local.fillchars:append({ fold = " " })
            end,
        })

        -- Auto-open folds when diagnostics exist inside them
        local fold_diag_group = vim.api.nvim_create_augroup("UfoDiagnosticAutoUnfold", { clear = true })
        vim.api.nvim_create_autocmd("DiagnosticChanged", {
            group = fold_diag_group,
            callback = function(args)
                local bufnr = args.buf
                local ft = vim.bo[bufnr].filetype
                if ft ~= "rust" and ft ~= "toml" then return end

                local diagnostics = vim.diagnostic.get(bufnr, {
                    severity = { min = vim.diagnostic.severity.WARN },
                })
                if #diagnostics == 0 then return end

                vim.api.nvim_buf_call(bufnr, function()
                    for _, diag in ipairs(diagnostics) do
                        local line = diag.lnum + 1
                        if vim.fn.foldclosed(line) ~= -1 then
                            vim.cmd(string.format("%dnormal! zv", line))
                        end
                    end
                end)
            end,
        })
    end,
    keys = {
        { "zR", function() require("ufo").openAllFolds() end,  desc = "Open all folds" },
        { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
        { "za", "za",                                          desc = "Toggle fold under cursor" },
    },
}
