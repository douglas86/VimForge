-- lua/plugins/session.lua

local function prune_orphaned_sessions()
    local session_dir = vim.fn.stdpath("state") .. "/sessions/"
    local files = vim.fn.glob(session_dir .. "*.vim", false, true)
    local current_cwd = vim.fn.getcwd()

    for _, file in ipairs(files) do
        local basename = vim.fs.basename(file)

        -- Strip .vim extension
        local clean_name = basename:gsub("%.vim$", "")

        -- If it starts with %, removing it before prefixing / avoids double-slashes
        if clean_name:sub(1, 1) == "%" then
            clean_name = clean_name:sub(2)
        end
        local original_dir = "/" .. clean_name:gsub("%%", "/")

        -- Resolve realpath in case ~/.config is a symlink or contains relative dots
        local real_dir = vim.uv.fs_realpath(original_dir) or original_dir

        -- NEVER delete the session for the project we are currently sitting in!
        if real_dir ~= current_cwd and vim.fn.isdirectory(real_dir) == 0 then
            os.remove(file)
        end
    end
end

local function open_project_entrypoint()
    local entrypoints = {
        "init.lua",
        "src/main.rs",
        "src/lib.rs",
        "Cargo.toml",
    }

    for _, rel_path in ipairs(entrypoints) do
        if vim.uv.fs_stat(rel_path) then
            vim.cmd.edit(rel_path)
            return
        end
    end
end

return {
    "folke/persistence.nvim",
    lazy = false,
    opts = {
        need = 1,
    },
    init = function()
        prune_orphaned_sessions()

        -- 1. Restore last cursor position when entering a buffer
        vim.api.nvim_create_autocmd("BufReadPost", {
            callback = function(args)
                local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
                local line_count = vim.api.nvim_buf_line_count(args.buf)
                if mark[1] > 0 and mark[1] <= line_count then
                    pcall(vim.api.nvim_win_set_cursor, 0, mark)
                end
            end,
        })

        -- 2. Close sidebars and guarantee a final save before exit
        vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                pcall(vim.api.nvim_command, "Neotree close")
                pcall(vim.api.nvim_command, "OutlineClose")

                local cwd = vim.fn.getcwd()
                if not (cwd:find("^/tmp") or cwd:find("^/var") or cwd:match("/%.git")) then
                    require("persistence").save()
                end
            end,
        })

        -- 3. Startup guard and autosave debouncing
        local started = false
        vim.api.nvim_create_autocmd("UIEnter", {
            once = true,
            callback = function()
                vim.defer_fn(function()
                    started = true
                end, 200)
            end,
        })

        local save_timer = nil
        local function trigger_session_save(buf)
            if not started then return end
            if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
                return
            end

            if save_timer then
                save_timer:stop()
            end

            save_timer = vim.defer_fn(function()
                require("persistence").save()
            end, 500)
        end

        local auto_save_group = vim.api.nvim_create_augroup("PersistenceAutoSave", { clear = true })

        vim.api.nvim_create_autocmd("BufWritePost", {
            group = auto_save_group,
            callback = function(args)
                if started and vim.bo[args.buf].buftype == "" and vim.api.nvim_buf_get_name(args.buf) ~= "" then
                    require("persistence").save()
                end
            end,
        })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
            group = auto_save_group,
            callback = function(args)
                trigger_session_save(args.buf)
            end,
        })

        -- 4. Auto-restore on startup
        vim.api.nvim_create_autocmd("VimEnter", {
            nested = true,
            callback = function()
                if vim.fn.argc() ~= 0 then
                    return
                end

                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                if #lines > 1 or (#lines == 1 and lines[1] ~= "") then
                    return
                end

                local cwd = vim.fn.getcwd()

                -- Skip transient directories
                if cwd:find("^/tmp") or cwd:find("^/var") or cwd:match("/%.git") then
                    return
                end

                -- Use persistence's native session locator for the current directory
                local session_file = require("persistence").current()

                if session_file and vim.uv.fs_stat(session_file) then
                    require("persistence").load()
                else
                    open_project_entrypoint()
                end
            end,
        })
    end,
}
