local wezterm = require("kola.wezterm")
local opts = { noremap = true, silent = true }

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
-- Editing
vim.keymap.set("n", "Y", "y$", opts)
vim.keymap.set("i", ",", ",<C-g>u", opts)
vim.keymap.set("i", ".", ".<C-g>u", opts)
vim.keymap.set("i", "!", "!<C-g>u", opts)
vim.keymap.set("i", "?", "?<C-g>u", opts)
vim.keymap.set("v", "<leader>p", '"_dP', opts)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Navigation
vim.keymap.set("n", "]b", ":bnext<CR>", opts)
vim.keymap.set("n", "[b", ":bprevious<CR>", opts)
vim.keymap.set("n", ",m", function()
    vim.cmd(":%s/\r//g")
end)
vim.keymap.set("n", "<C-j>", wezterm.down, opts)
vim.keymap.set("n", "<C-h>", wezterm.left, opts)
vim.keymap.set("n", "<C-k>", wezterm.up, opts)
vim.keymap.set("n", "<C-l>", wezterm.right, opts)
vim.keymap.set("n", "H", ":bp<CR>", opts)
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)
vim.keymap.set("n", "H", ":bp<CR>", opts)
vim.keymap.set("n", "<C-W>", ":%bd!|e#<CR>", opts)
vim.keymap.set("n", "q", function()
    local tabNumber = vim.fn.tabpagenr()
    if tabNumber > 1 then
        vim.cmd("tabclose")
    else
        local key = vim.api.nvim_replace_termcodes("q", true, false, true)
        vim.api.nvim_feedkeys(key, "n", false)
    end
end)
vim.keymap.set("n", "Q", "@qj", opts)
vim.keymap.set("v", "Q", ":norm @q<CR>", opts)

-- Resize with arrows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<leader>y", ":let @+ = expand('%')<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)
vim.keymap.set("n", "<leader>rl", function()
    vim.cmd("luafile %")
end)
