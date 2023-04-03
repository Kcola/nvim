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
    filesystem = {
        follow_current_file = true, -- This will find and focus the file in the active buffer every
    },
    buffers = {
        follow_current_file = true, -- This will find and focus the file in the active buffer every
    },
})

vim.keymap.set("n", "<leader>t", function()
    vim.cmd([[Neotree toggle]])
end, { desc = "toggle tree" })
