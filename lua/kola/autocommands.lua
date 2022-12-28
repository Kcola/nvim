local function view_commit()
	local line = vim.fn.getline(".")
	vim.cmd("DiffviewOpen " .. line:firstword() .. "^!")
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "git",
	callback = function()
		vim.keymap.set("n", "<cr>", view_commit, { noremap = true, silent = true, buffer = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "git",
	command = "nnoremap <buffer><silent> q <cmd>q<cr>",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "fugitiveblame",
	callback = function()
		vim.keymap.set("n", "<cr>", view_commit, { noremap = true, silent = true, buffer = true })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "fugitiveblame",
	command = "nnoremap <buffer><silent> q <cmd>q<cr>",
})
