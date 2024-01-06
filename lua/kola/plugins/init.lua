return {
    { "sitiom/nvim-numbertoggle" },
    {
        "m4xshen/hardtime.nvim",
        depnndencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
        opts = {
            restriction_mode = "hint",
            disable_mouse = false,
        },
    },
    "github/copilot.vim",
    "neovim/nvim-lspconfig",
    { "j-hui/fidget.nvim", tag = "legacy" },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    },
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/playground",
    "tpope/vim-fugitive",
    "tpope/vim-rhubarb",
    "tpope/vim-sleuth",
    "nvim-telescope/telescope-fzf-native.nvim",
    "ojroques/nvim-bufdel",
}
