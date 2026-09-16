-- lua/core/buffer_reaper.lua
local M = {}

-- Maximum number of hidden/background buffers to keep alive
local MAX_HIDDEN_BUFFERS = 10

-- Table tracking the last access timestamp for each buffer ID
local access_times = {}

function M.prune_hidden_buffers()
    -- 1. Identify all currently visible buffers across all windows and tabs
    local visible_buffers = {}
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            local buf = vim.api.nvim_win_get_buf(win)
            visible_buffers[buf] = true
        end
    end

    -- 2. Filter candidate hidden buffers eligible for pruning
    local hidden_candidates = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf)
            and not visible_buffers[buf]
            and vim.bo[buf].buflisted
            and vim.bo[buf].buftype == ""
            and not vim.bo[buf].modified
        then
            table.insert(hidden_candidates, {
                buf = buf,
                last_used = access_times[buf] or 0,
            })
        end
    end

    -- 3. If hidden buffers exceed the threshold, delete the oldest
    if #hidden_candidates > MAX_HIDDEN_BUFFERS then
        -- Sort ascending: oldest accessed first
        table.sort(hidden_candidates, function(a, b)
            return a.last_used < b.last_used
        end)

        local to_remove_count = #hidden_candidates - MAX_HIDDEN_BUFFERS
        for i = 1, to_remove_count do
            local target_buf = hidden_candidates[i].buf
            -- Delete the buffer silently without affecting split layout
            vim.api.nvim_buf_delete(target_buf, { unload = false })
            access_times[target_buf] = nil
        end
    end
end

-- Track access time when a buffer is entered
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("BufferReaper", { clear = true }),
    callback = function(args)
        if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].buflisted then
            access_times[args.buf] = vim.uv.now()
            M.prune_hidden_buffers()
        end
    end,
})

return M
