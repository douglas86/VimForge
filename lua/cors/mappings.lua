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

	map('n', '<leader>q', ':q<CR>', { noremap = true, silent = true })
	map('n', '<leader>w', ':qall<CR>', { noremap = true, silent = true })

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
    keys("n", "<leader>e", ":Neotree toggle<CR>") -- toggles neo tree open or close
    keys("n", "<leader>o", ":Neotree focus<CR>") -- focus on neo tree if open
    -- Telescope - project searching
    keys("n", "<leader>f", ":Telescope find_files<CR>") -- find files inside current directory
    keys("n", "<leader>d", ":Telescope live_grep<CR>") -- find words or phrases inside files in current directory
    -- LazyGit
    keys("n", "<leader>g", ":LazyGit<CR>")
    -- diagnostic keymaps
    vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', {noremap=true, silent=true})
    vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', {noremap=true, silent=true})

    -- insert mode keymaps
    vim.api.nvim_set_keymap("i", "<CR>", [[v:lua.require('nvim-autopairs').autopairs_cr()]], { noremap = true, expr = true, silent = true, })

    -- Folding of function and classes
    vim.api.nvim_set_keymap('n', 'zR', ':lua vim.cmd("set foldlevel=99")<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'zM', ':lua vim.cmd("set foldlevel=0")<CR>', { noremap = true, silent = true })

end

return M
