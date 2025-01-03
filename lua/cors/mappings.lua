local M = {}

function M.setup()
	local function map(mode, lhs, rhs, opts)
		local options = { noremap = true, silent = true }

		if opts then
			options = vim.tbl_extend('force', options, opts)
		end
		vim.api.nvim_set_keymap(mode, lhs, rhs, options)
	end

	-- set leader key
	vim.g.mapleader = ' ' -- Set space as leader key

	map('n', 'q', ':q<CR>', { noremap = true, silent = true, desc="Quit current file" })
	map('n', 'Q', ':qall<CR>', { noremap = true, silent = true, desc="Quit all files" })

end

function M.keybindings()
    local function keys(mode, lhs, rhs, opts)
        local options = { silent = true, noremap = true }

        if opts then
            options = vim.tbl_extend('force', options, opts)
        end

        vim.keymap.set(mode, lhs, rhs, options)
    end

    -- set leader key
    vim.g.mapleader = ' ' -- set space as leader key

    -- normal mode keymaps
    -- neo tree - File Explorer
    keys("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle Neotree"}) -- toggles neo tree open or close
    keys("n", "<leader>o", ":Neotree focus<CR>", { desc = "Focus on Neotree" }) -- focus on neo tree if open
    -- Telescope - project searching
    keys("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Search for files with current project" }) -- find files inside current directory
    keys("n", "<leader>d", ":Telescope live_grep<CR>", { desc = "Search within files of current project" }) -- find words or phrases inside files in current directory
    -- LazyGit
    keys("n", "<leader>g", ":LazyGit<CR>", { desc = "Open LazyGit" })
    -- diagnostic keymaps
    vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', { noremap=true, silent=true, desc="jump to previous diagnostic step" })
    vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', { noremap=true, silent=true, desc="jump to next diagnostic step" })

    -- insert mode keymaps
    vim.api.nvim_set_keymap("i", "<CR>", [[v:lua.require('nvim-autopairs').autopairs_cr()]], { noremap = true, expr = true, silent = true, desc="indent when enter pressed inside of brackets" })

    -- Folding of function and classes
    vim.api.nvim_set_keymap('n', 'zR', ':lua vim.cmd("set foldlevel=99")<CR>', { noremap = true, silent = true, desc="un fold all functions and classes in current file" })
    vim.api.nvim_set_keymap('n', 'zM', ':lua vim.cmd("set foldlevel=0")<CR>', { noremap = true, silent = true, desc="fold all functions and classes in current file" })

    -- Load all shortcuts
    vim.api.nvim_set_keymap('n', 't', ':Telescope keymaps<CR>', { noremap = true, silent = true, desc = "find all shortcut keys" })

    -- note taking shortcuts
    keys("n", "zn", ":Telekasten new_note<CR>", { desc = "New Note" })
    keys("n", "zf", ":Telekasten find_notes<CR>", { desc = "Find Notes" })
    keys("n", "zd", ":Telekasten goto_today<CR>", { desc = "Daily Notes" })
    keys("n", "zw", ":Telekasten goto_thisweek<CR>", { desc = "Weekly Notes" })
    keys("n", "zi", ":Telekasten insert_link<CR>", { desc = "Insert Link" })
    keys("n", "zp", ":Telekasten panel<CR>", { desc = "Note taking panel" })
    keys("n", "zz", ":Telekasten toggle_todo<CR>", { desc = "toggle checkbox in notes" })

    keys("n", "zg", function()
        require("telescope.builtin").live_grep({
            cwd = vim.fn.expand("~/.config/nvim/notes"),
            additional_args = function()
                return {
                    "--glob=!templates/**",
                    "--glob=!images/**",
                }
            end,
        })
    end, { desc = "Live Grep in Notes" })
end

return M
