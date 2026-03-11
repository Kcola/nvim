return {
    "stevearc/oil.nvim",
    config = function()
        require("oil").setup({
            keymaps = {
                ["q"] = { "actions.close", mode = "n" },
            },
        })
        vim.keymap.set("n", "<leader>t", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end,
}
