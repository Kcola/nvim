return {
    "mhartington/formatter.nvim",
    dependencies = {
        "numToStr/Comment.nvim",
        "lukas-reineke/indent-blankline.nvim",
    },
    config = function()
        -- Enable Comment.nvim
        require("Comment").setup()

        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        require("indent_blankline").setup({
            char = "┊",
            show_trailing_blankline_indent = false,
        })

        local util = require("formatter.util")

        local get_package_root = function()
            local package_json_path = vim.fn.findfile("package.json", vim.fn.expand("%:p:h") .. ";")
            --get full path
            return vim.fn.fnamemodify(package_json_path, ":p:h") .. "/"
        end

        local function eslint()
            local root = get_package_root()
            return {
                exe = "eslint_d",
                args = {
                    "--stdin",
                    "--stdin-filename",
                    util.escape_path(util.get_current_buffer_file_path()),
                    "--fix-to-stdout",
                },
                cwd = root,
                stdin = true,
                try_node_modules = true,
            }
        end

        require("formatter").setup({
            logging = true,
            log_level = vim.log.levels.WARN,
            filetype = {
                lua = {
                    require("formatter.filetypes.lua").stylua,
                },
                typescript = {
                    eslint,
                },
                javascript = {
                    eslint,
                },
                typescriptreact = {
                    eslint,
                },
                json = {
                    require("formatter.filetypes.json").prettier,
                },
            },
        })

        local augroup = vim.api.nvim_create_augroup("Formatter", { clear = true })

        vim.api.nvim_create_autocmd("BufWritePost", {
            group = augroup,
            pattern = "*",
            command = "FormatWrite",
        })
    end,
}
