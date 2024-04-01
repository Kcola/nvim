return { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    config = function()
        require("nvim-treesitter.configs").setup({
            highlight = {
                enable = true,
            },
            ensure_installed = { "lua", "typescript", "c_sharp", "javascript", "json" },
            sync_install = true,
            build = ":TSUpdate",
            indent = { enable = true },
        })
        local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

        parser_config.nu = {
            install_info = {
                url = "https://github.com/nushell/tree-sitter-nu",
                files = { "src/parser.c" },
                branch = "main",
            },
            filetype = "nu",
        }
    end,
}
