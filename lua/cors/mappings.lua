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

return M
