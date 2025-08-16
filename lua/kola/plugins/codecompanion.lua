return {
    "olimorris/codecompanion.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("codecompanion").setup({
            {
                display = {
                    chat = {
                        window = {
                            width = 0.2,
                        },
                    },
                },
                strategies = {
                    inline = {
                        keymaps = {
                            accept_change = {
                                modes = { n = "ga" },
                                description = "Accept the suggested change",
                            },
                            reject_change = {
                                modes = { n = "q" },
                                opts = { nowait = true },
                                description = "Reject the suggested change",
                            },
                        },
                    },
                },
            },
        })

        vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
        vim.keymap.set(
            { "n", "v" },
            "<LocalLeader>a",
            "<cmd>CodeCompanionChat Toggle<cr>",
            { noremap = true, silent = true }
        )
        vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

        -- Expand 'cc' into 'CodeCompanion' in the command line
        vim.cmd([[cab cc CodeCompanion]])
    end,
}
