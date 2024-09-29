return {
    "numToStr/Navigator.nvim",
    config = function()
        local navigator = require("Navigator")

        navigator.setup()

        vim.keymap.set("n", "<c-h>", navigator.left, { desc = "jump to left pane" })
        vim.keymap.set("n", "<c-j>", navigator.down, { desc = "jump to below pane" })
        vim.keymap.set("n", "<c-k>", navigator.up, { desc = "jump to above pane" })
        vim.keymap.set("n", "<c-l>", navigator.right, { desc = "jump to right pane" })
    end,
}
