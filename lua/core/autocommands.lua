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

-- Create an autocommand that runs automatically right before saving a markdown buffer
vim.api.nvim_create_autocmd("BufWritePre", {
  buffer = 0,
  desc = "Automatically inject emojis into markdown headings before saving",
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local changed = false

    for i, line in ipairs(lines) do
      -- Matches any heading line like: "^(##+)%s+(.*)$"
      local hashes, rest = line:match("^(#+)%s+(.*)$")
      if hashes and heading_emojis[hashes] then
        local emoji = heading_emojis[hashes]

        -- If the heading doesn't already start with an emoji, add it
        -- (Checks if the first character is not plain ASCII alphanumeric)
        local first_char = rest:match("^([^%w%s%p])")
        if not first_char then
          lines[i] = string.format("%s %s %s", hashes, emoji, rest)
          changed = true
        end
      end
    end

    if changed then
      -- Save cursor position to prevent cursor jumping
      local cursor = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
      pcall(vim.api.nvim_win_set_cursor, 0, cursor)
    end
  end,
})
