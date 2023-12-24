return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter",
        { "Kcola/neotest-jest" },
    },
    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-jest"),
            },

            output = {
                enabled = false,
            },
            output_panel = {
                enabled = true,
                open = "vsplit",
            },
        })
        vim.keymap.set("n", "<leader>J", function()
            require("neotest").run.run()
            require("neotest").output_panel.open()
        end, { desc = "run nearest test" })
    end,
}
