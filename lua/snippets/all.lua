local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Extracts the comment prefix (eg., "-- " for Lua, "// " for Rust)
local function get_comment_leader()
    local cs = vim.bo.commentstring
    if cs == "" or not cs:find("%%s") then
        return "// "
    end
    return cs:gsub("%%s.*", "")
end

local function make_todo_snippet(trigger, tag)
    return s(trigger, {
        f(get_comment_leader, {}),
        t(tag .. ": "),
        i(1, "description"),
    })
end

return {
    make_todo_snippet("todo", "TODO"),
    make_todo_snippet("fix", "FIX"),
    make_todo_snippet("note", "NOTE"),
    make_todo_snippet("warn", "WARN"),
    make_todo_snippet("perf", "PERF"),
    make_todo_snippet("hack", "HACK"),
}
