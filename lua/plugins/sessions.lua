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
                local session_file = vim.fn.stdpath("state") .. "/session/" .. cwd:gsub("/", "%%") .. ".vim"

                if vim.uv.fs_stat(session_file) then
                    require("persistence").load()
                else
                    open_project_entrypoint()
                end
            end,
        })
    end,
}
