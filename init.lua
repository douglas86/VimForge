-- ~/.config/nvim/init.lua

-- NOTE: I have fixed the invalid api key that I was getting
-- -- FIX: I am receiving a 429 error code from gemini for max quota reached
-- -- TODO: Fix issue above and getting gemini to respond with the correct messages
-- -- TODO: change gemini to be a floating window instead of a split

-- Enable the fast loader first
if vim.loader then
    vim.loader.enable()
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

require("core.settings")
require("config.lazy")
require("core.autocommands")
require("core.options")
