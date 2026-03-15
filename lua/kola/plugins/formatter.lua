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
        local work_config = (function()
            local ok, cfg = pcall(require, "kola.work_config")
            return ok and cfg or { biome_projects = {}, custom_eslint_projects = {} }
        end)()

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

        local function biome()
            return {
                exe = "biome",
                args = {
                    "format",
                    "--write",
                    "--stdin-file-path",
                    util.escape_path(util.get_current_buffer_file_path()),
                },
                cwd = get_package_root(),
                stdin = true,
                try_node_modules = true,
            }
        end

        local function eslint_or_biome()
            local projectName = utils.get_git_repo_name()
            for _, name in ipairs(work_config.biome_projects) do
                if projectName == name then
                    return biome()
                end
            end
            return eslint()
        end

        local function prettier_or_biome()
            local projectName = utils.get_git_repo_name()
            for _, name in ipairs(work_config.biome_projects) do
                if projectName == name then
                    return biome()
                end
            end
            return require("formatter.filetypes.json").prettier()
        end

        local function eslint()
            local root = get_package_root()
            local projectName = utils.get_git_repo_name()

            local build_scripts_path = vim.fn.finddir("packages", ";") .. "/build-scripts"

            local use_custom_eslint = false
            for _, name in ipairs(work_config.custom_eslint_projects) do
                if projectName == name then
                    use_custom_eslint = true
                    break
                end
            end

            if not use_custom_eslint then
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
                    eslint_or_biome,
                },
                javascript = {
                    prettier_or_biome,
                },
                typescriptreact = {
                    eslint_or_biome,
                },
                json = {
                    prettier_or_biome,
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
