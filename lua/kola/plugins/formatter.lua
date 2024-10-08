return {
    "mhartington/formatter.nvim",
    dependencies = {
        "numToStr/Comment.nvim",
        "lukas-reineke/indent-blankline.nvim",
    },
    config = function()
        -- Enable Comment.nvim
        require("Comment").setup()
        local ft = require("Comment.ft")
        ft.set("json", "//%s")

        local utils = require("kola.utils")
        local formattingUtils = require("formatter.util")

        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help indent_blankline.txt`
        require("ibl").setup({
            debounce = 100,
            indent = { char = "┊" },
            whitespace = { highlight = { "Whitespace", "NonText" } },
            scope = { exclude = { language = { "lua" } } },
        })

        local util = require("formatter.util")

        local get_package_root = function()
            local package_json_path = vim.fn.findfile("package.json", vim.fn.expand("%:p:h") .. ";")
            --get full path
            return vim.fn.fnamemodify(package_json_path, ":p:h") .. "/"
        end

        local function eslint()
            local root = get_package_root()
            local projectName = utils.get_git_repo_name()

            local build_scripts_path = vim.fn.finddir("packages", ";") .. "/build-scripts"

            if projectName ~= "power-platform-ux" then
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
            else
                return {
                    exe = "eslint_d",
                    args = {
                        "--stdin",
                        "--stdin-filename",
                        formattingUtils.escape_path(formattingUtils.get_current_buffer_file_path()),
                        "--fix-to-stdout",
                        "--rulesdir",
                        build_scripts_path .. "/lib/eslint-rules",
                        "--resolve-plugins-relative-to",
                        build_scripts_path .. "/node_modules",
                        "--eslint-path",
                        build_scripts_path .. "/node_modules/eslint",
                    },
                    stdin = true,
                    try_node_modules = true,
                }
            end
        end

        require("formatter").setup({
            logging = true,
            log_level = vim.log.levels.WARN,
            filetype = {
                fish = {
                    require("formatter.filetypes.fish").fishindent,
                },
                lua = {
                    require("formatter.filetypes.lua").stylua,
                },
                typescript = {
                    eslint,
                },
                javascript = {
                    require("formatter.filetypes.json").prettier,
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
