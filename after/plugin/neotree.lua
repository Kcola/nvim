require("neo-tree").setup({
    close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
    window = {
        position = "float",
        width = 40,
        mapping_options = {
            noremap = true,
            nowait = true,
        },
        mappings = {
            ["<esc>"] = "close_window",
        },
    },
    nesting_rules = {},
})

vim.keymap.set("n", "<leader>t", function()
    vim.cmd([[Neotree toggle reveal]])
end, { desc = "toggle tree" })
