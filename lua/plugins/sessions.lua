-- lua/plugins/session.lua

local function prune_orphaned_sessions()
    local session_dir = vim.fn.stdpath("state") .. "/sessions/"
    local files = vim.fn.glob(session_dir .. "*.vim", false, true)

    for _, file in ipairs(files) do
        local basename = vim.fs.basename(file)
        -- Convert %home%user%project.vim back to /home/user/project
        local original_dir = basename:gsub("%%", "/"):gsub("%.vim$", "")

        -- If the original directory no longer exists on disk, delete the session file
        if vim.fn.isdirectory(original_dir) == 0 then
            os.remove(file)
        end
    end
end

-- Check candidates in priority order' open the first one found
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
    -- Load immediately or very early so the save-on-exit hook is always active
    lazy = false,
    opts = {
        need = 1,
    },
    init = function()
        -- Prune dead sessions on startup
        prune_orphaned_sessions()

        -- Track when Neovim startup has completed
        local started = false
        vim.api.nvim_create_autocmd("UIEnter", {
            once = true,
            callback = function()
                vim.defer_fn(function()
                    started = true
                end, 300)
            end,
        })

        -- Debounced auto-save timer for view-only browsing
        local save_timer = nil
        local function trigger_session_save(buf)
            if not started then return end

            -- Only save for genuine, named disk files (ignore Telescope, floats, help)
            if vim.bo[buf].buftype ~= "" or vim.api.nvim_buf_get_name(buf) == "" then
                return
            end

            -- Debounce writes by 500ms so browsing files doesn't hammer disk IO
            if save_timer then
                save_timer:stop()
            end

            save_timer = vim.defer_fn(function()
                require("persistence").save()
            end, 500)
        end

        local auto_save_group = vim.api.nvim_create_augroup("PersistenceAutoSave", { clear = true })

        -- 1. Save immediately on explicit file write
        vim.api.nvim_create_autocmd("BufWritePost", {
            group = auto_save_group,
            callback = function(args)
                if started and vim.bo[args.buf].buftype == "" and vim.api.nvim_buf_get_name(args.buf) ~= "" then
                    require("persistence").save()
                end
            end,
        })

        -- 2. Save on buffer navigation / viewing (debounced)
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
            group = auto_save_group,
            callback = function(args)
                trigger_session_save(args.buf)
            end,
        })

        -- Auto-restore on startup if Neovim is launched with no file arguments
        vim.api.nvim_create_autocmd("VimEnter", {
            nested = true,
            callback = function()
                -- Skip if arguments were passed (e.g. nvim file.rs)
                if vim.fn.argc() ~= 0 then
                    return
                end

                -- Skip if stdin was piped in
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                if #lines > 1 or (#lines == 1 and lines[1] ~= "") then
                    return
                end

                -- Determine session path for current working directory
                local cwd = vim.fn.getcwd()
                local session_file = vim.fn.stdpath("state") .. "/sessions/" .. cwd:gsub("/", "%%") .. ".vim"

                if vim.uv.fs_stat(session_file) then
                    require("persistence").load()
                else
                    open_project_entrypoint()
                end
            end,
        })
    end,
}
