-- Enable Comment.nvim
require("Comment").setup()

-- Enable `lukas-reineke/indent-blankline.nvim`
-- See `:help indent_blankline.txt`
require("indent_blankline").setup({
	char = "┊",
	show_trailing_blankline_indent = false,
})

require("formatter").setup({
	filetype = {
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
	},
})

local augroup = vim.api.nvim_create_augroup("Formatter", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
	group = augroup,
	pattern = "*",
	command = "FormatWrite",
})
