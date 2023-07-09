local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "wbthomason/packer.nvim",
    "github/copilot.vim",
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    { "j-hui/fidget.nvim", tag = "legacy" },
    { "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" } },
    { -- Highlight, edit, and navigate code
        "nvim-treesitter/nvim-treesitter",
        config = function()
            pcall(require("nvim-treesitter.install").update({ with_sync = true }))
        end,
    },
    "nvim-treesitter/nvim-treesitter-textobjects",
    "nvim-treesitter/playground",
    "tpope/vim-fugitive",
    "tpope/vim-rhubarb",
    "lewis6991/gitsigns.nvim",
    {
        "lunarvim/darkplus.nvim",
        lazy = false, -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            vim.cmd([[colorscheme darkplus]])
        end,
    },

    "nvim-lualine/lualine.nvim",
    "lukas-reineke/indent-blankline.nvim",
    "numToStr/Comment.nvim",
    "tpope/vim-sleuth",

    { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },

    "nvim-telescope/telescope-fzf-native.nvim",

    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- optional, for file icons
        },
        tag = "nightly", -- optional, updated every week. (see issue #1193)
    },
    "akinsho/toggleterm.nvim",
    {
        "sindrets/diffview.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        commit = "4a55b5e2d2c3d6bd89cd3299a9ca276d49d25463",
    },
    "mhartington/formatter.nvim",
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
    },

    {
        "rmagatti/auto-session",
        config = function()
            require("auto-session").setup({
                log_level = "error",
                auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
            })
        end,
    },
})
