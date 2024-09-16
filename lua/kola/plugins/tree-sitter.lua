return { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = {
                enable = true,
            },
            ensure_installed = { "lua", "typescript", "c_sharp", "javascript", "json", "nu" },
            sync_install = true,
            build = ":TSUpdate",
            indent = { enable = true },
        })
    end,
    dependencies = {
        -- NOTE: additional parser
        { "nushell/tree-sitter-nu" },
    },
    build = ":TSUpdate",
}
