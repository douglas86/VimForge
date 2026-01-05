-- ~/.config/nvim/core/diagnostics

-- global variables
-- _G.ProjectStats = { errors = 0, warnings = 0 }

-- local variables
local config = vim.lsp.config
-- local diagnostics = vim.diagnostic.config
-- local enable = vim.lsp.enable
-- local key = vim.keymap.set
-- local project_timer = nil
-- local pyright_config = {
--     name = 'pyright',
--     cmd = { 'pyright-langserver', '--stdio' },
--     settings = {
--         python = {
--             analysis = {
--                 diagnosticMode = "workspace",
--             }
--         }
--     }
-- }

-- configs
config('pyright', {
    settings = {
        python = {
            analysis = {
                diagnosticMode = "workspace",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
            }
        }
    }
})

config('lua_ls', {
    settings = {
        Lua = {
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { 'vim' },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
            }
        }
    }
})

-- Show error, warning, hint and info sign in the column
-- diagnostics({
--     virtual_text = true,
--     underline = true,
--     update_in_insert = false,
--     severity_sort = true,
--     signs = {
--       text = {
--         [vim.diagnostic.severity.ERROR] = "", -- Your Bug Icon
--         [vim.diagnostic.severity.WARN]  = "", -- Warning
--         [vim.diagnostic.severity.HINT]  = "󰌵", -- Hint
--         [vim.diagnostic.severity.INFO]  = "", -- nfo
--       },
--     },
-- })
-- 
-- -- Set the color for Warnings to a bright, vibrant Yellow/Orrange
-- vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = "#FFA500", bold = true })
-- vim.api.nvim_set_hl(0, "DiagnosticSignWarn", { fg = "#FFA500", bold = true })
-- -- Set the color for Errors to a bright Red
-- vim.api.nvim_set_hl(0, "DiagnosticError", { fg = "#FF3131", bold = true })
-- 
-- -- enable
-- enable('pyright')
-- 
-- -- setup
-- vim.lsp.config('pyright', {
--     install = {
--         -- This tells Neovim how to handle the server
--     },
--     default_config = pyright_config
-- })
-- 
-- local function update_global_diagnostics()
--     -- We use vim.schedule to ensure we don't block the UI
--     vim.schedule(function()
--         local count = vim.diagnostic.get_count(0, { severity = vim.diagnostic.severity.ERROR })
--         -- Update the global table
--         _G.ProjectStats.errors = count
-- 
--         -- Force Lualine to look at the new data
--         require('lualine').refresh()
--     end)
-- end
-- 
-- local function debounced_project_update()
--     if project_timer  then
--         project_timer:stop()
--         project_timer:close()
--     end
-- 
--     project_timer = vim.uv.new_timer()
--     if project_timer  then
--         project_timer:start(500, 0, vim.schedule.wrap(function()
--             update_global_diagnostics()
--             project_timer = nil
--         end))
--     end
-- end
-- 
-- require('lualine').setup({
--   options = {
--     theme = 'auto', -- Automatically matches your colorscheme
--     component_separators = { left = '', right = ''},
--     section_separators = { left = '', right = ''},
--     globalstatus = true, -- One statusline for all windows (cleaner look)
--   },
--   sections = {
--     lualine_b = { 'branch', 'diff', 'diagnostics' },
--     lualine_c = { { 'filename', path = 1 } }, -- 'path = 1' shows relative path
--     lualine_x = { {
--         function()
--           local qf_count = #vim.fn.getqflist()
--           local loc_count = #vim.fn.getloclist(0)
--           -- Returns "🌐 0 📍 0" even if no errors exist
--           return string.format("🌐 %d 📍 %d", qf_count, loc_count)
--         end,
--         color = { fg = '#ff9e64' }, -- Optional: pick a color    
--     }, 'encoding', 'fileformat', 'filetype' },
--   }
-- })
-- 
-- -- key
-- -- Jump to the NEXT diagnostic (Warning/Error)
-- key('n', ']d', function()
--     vim.diagnostic.jump({ count = 1, float = true })
-- end, { desc = 'Go to next diagnostic' })
-- -- Jump to the Previous diagnostic
-- key('n', '[d', function()
--     vim.diagnostic.jump({ count = -1, float = true })
-- end, { desc = 'Go to previous diagnostic' })
-- -- Optional: Jump only on ERRORS (skipping warnings)
-- key('n', ']e', function()
--     vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
-- end, { desc = "Previous error" })
-- -- Open all diagnostics for the current buffer in a list
-- key('n', ']l', vim.diagnostic.setloclist, { desc = "Open diagnostic list" })
-- key('n', '[l', '<cmd>lclose<cr>', { desc = 'Close Location List' })
-- -- Open all diagnostics for the entire project in a list
-- key('n', ']g', vim.diagnostic.setqflist, { desc = "Open project diagnostics list" })
-- key('n', '[g', '<cmd>cclose<cr>', { desc = 'Close Quickfix List' })
