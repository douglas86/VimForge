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

    keys("n", "<leader>e", ":Neotree toggle<CR>")
    keys("n", "<leader>o", ":Neotree focus<CR>")

end

return M
