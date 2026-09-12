-- ~/.config/nvim/lua/core/autocommands.lua

-- local variables
local opt = vim.opt
-- local timer = nil
local auto = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup

local heading_emojis = {
    ["#"]      = "🏷️",
    ["##"]     = "📌",
    ["###"]    = "📦",
    ["####"]   = "🔹",
    ["#####"]  = "▫️",
    ["######"] = "🔸",
}

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

-- Create a reverse lookup to avoid re-adding if an emoji already exists
local emoji_lookup = {}
for _, e in pairs(heading_emojis) do
    emoji_lookup[e] = true
end

-- Adds emojis to the front of the headings in markdown files
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.md", "*.markdown" },
    desc = "Automatically inject emojis into markdown headings before saving",
    callback = function(args)
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
        local changed = false

        for i, line in ipairs(lines) do
            -- Matches any heading: starts with 1-6 hashes, followed by spaces, then the rest
            local hashes, rest = line:match("^(#+)%s+(.*)$")
            if hashes and heading_emojis[hashes] then
                local expected_emoji = heading_emojis[hashes]

                -- Check if the line already starts with ANY of our configured emojis
                local already_has_emoji = false
                for _, e in pairs(heading_emojis) do
                    if vim.startswith(rest, e) then
                        already_has_emoji = true
                        break
                    end
                end

                -- If it doesn't have an emoji, inject it
                if not already_has_emoji then
                    lines[i] = string.format("%s %s %s", hashes, expected_emoji, rest)
                    changed = true
                end
            end
        end

        if changed then
            local cursor = vim.api.nvim_win_get_cursor(0)
            vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
            pcall(vim.api.nvim_win_set_cursor, 0, cursor)
        end
    end,
})

-- Deletes all unneccarry blank lines in Lua files
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*.lua",
    desc = "Collapse multiple consecutive empty lines to a single empty line",
    callback = function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        -- Replaces any occurrence of 2 or more consecutive blank lines with 1
        vim.cmd([[%s/\n\{3,}/\r\r/e]])
        pcall(vim.api.nvim_win_set_cursor, 0, cursor)
    end,
})
