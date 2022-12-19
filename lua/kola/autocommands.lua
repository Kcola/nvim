vim.api.nvim_create_autocmd("FileType", {
	pattern = "git",
	command = "nnoremap <buffer><silent> <cr> <cmd>lua require('kola.diffview').view_commit()<cr>",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "git",
	command = "nnoremap <buffer><silent> q <cmd>q<cr>",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "fugitiveblame",
	command = "nnoremap <buffer><silent> <cr> <cmd>lua require('kola.diffview').view_commit()<cr>",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "fugitiveblame",
	command = "nnoremap <buffer><silent> q <cmd>q<cr>",
})
