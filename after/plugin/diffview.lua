-- Lua
local opts = { noremap = true, silent = true }
local actions = require("diffview.actions")
local lazy = require("diffview.lazy")
local lib = lazy.require("diffview.lib")
local gs = require("gitsigns")

local goto_file = function()
	actions.goto_file()
	vim.fn.feedkeys("zR")
end

local goto_file_and_close = function()
	goto_file()
	vim.cmd("only")
	vim.cmd("tabonly")
	vim.fn.feedkeys("zR")
end

local open = function()
	vim.cmd("DiffviewOpen")
end

local load_files_into_buffer = function()
	for _, filetree in pairs(lib.get_current_view().files) do
		for _, value in ipairs(filetree) do
			vim.fn.bufload(vim.fn.bufadd(value.absolute_path))
		end
	end
	P("All change files loaded")
end

require("diffview").setup({
	key_bindings = {
		file_panel = {
			s = actions.toggle_stage_entry,
			["<cr>"] = goto_file_and_close,
			["cc"] = "<Cmd>botright Git commit<CR>",
			["<2-LeftMouse>"] = actions.select_entry,
		},
		diff_view = {
			["<Down>"] = gs.next_hunk,
			["<Up>"] = gs.prev_hunk,
		},
	},
})

function string:firstword()
	return self:match("^([%w]+)")
end

vim.keymap.set("n", "gs", open)
vim.keymap.set("n", "<leader>history", "<cmd>DiffviewFileHistory %<cr>", opts)

return {
	view_commit = view_commit,
}
