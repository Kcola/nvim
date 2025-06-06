return {
    "kdheepak/lazygit.nvim",
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        vim.keymap.set("n", "gs", "<cmd>LazyGit<cr>", {
            desc = "Open LazyGit",
        })
    end,
}
