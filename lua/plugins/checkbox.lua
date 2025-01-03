local M = {}

M.toggle_checkbox = function()
    local line = vim.fn.getline(".") -- Get the current line's content
    local line_number = vim.fn.line(".") -- Get the current line number

    -- Check for an unchecked box and toggle to checked
    if line:match("%- %[ %]") then
        vim.fn.setline(line_number, line:gsub("%- %[ %]", "- [x]", 1))
    -- Check for a checked box and toggle to unchecked
    elseif line:match("%- %[x%]") then
        vim.fn.setline(line_number, line:gsub("%- %[x%]", "- [ ]", 1))
    else
        print("No checkbox found on this line.")
    end
end

return M

