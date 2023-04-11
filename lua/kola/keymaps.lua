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

-- Navigation
vim.keymap.set("n", "H", ":bp<CR>", opts)
vim.keymap.set("n", "<C-j>", "<C-W><Down>", opts)
vim.keymap.set("n", "<C-h>", "<C-W><Left>", opts)
vim.keymap.set("n", "<C-k>", "<C-W><Up>", opts)
vim.keymap.set("n", "<C-l>", "<C-W><Right>", opts)
vim.keymap.set("i", "<Up>", "<Nop>", opts)
vim.keymap.set("i", "<Down>", "<Nop>", opts)
vim.keymap.set("i", "<Left>", "<Nop>", opts)
vim.keymap.set("i", "<Right>", "<Nop>", opts)
vim.keymap.set("n", "L", ":bn<CR>", opts)
vim.keymap.set("n", "H", ":bp<CR>", opts)
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)
vim.keymap.set("n", "H", ":bp<CR>", opts)
vim.keymap.set("n", "<C-W>", ":%bd!|e#<CR>", opts)
vim.keymap.set("n", "q", function()
    local tabNumber = vim.fn.tabpagenr()
    if tabNumber > 1 then
        vim.cmd("tabclose")
    end
end)

-- Resize with arrows
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)
vim.keymap.set("n", "<leader>rl", function()
    vim.cmd("luafile %")
end)
vim.api.nvim_set_keymap("i", "<leader>cp", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<Tab>", "pumvisible() ? '<C-n>' : '<Tab>'", { expr = true })
