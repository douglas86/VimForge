require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    change_detection = {
        enabled = true,
        notify = false,
    }
})
