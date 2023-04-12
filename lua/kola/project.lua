local utils = require("kola.utils")
local lsp = require("lspconfig")
local formattingUtils = require("formatter.util")

local projectName = utils.get_git_repo_name()

if projectName == "power-platform-ux" then
    local build_scripts_path = vim.fn.finddir("packages", ";") .. "/build-scripts"
    lsp.eslint.setup({
        settings = {
            nodePath = build_scripts_path .. "/node_modules",
            options = {
                rulePaths = { build_scripts_path .. "/lib/eslint-rules" },
                resolvePluginsRelativeTo = build_scripts_path .. "/node_modules",
            },
        },
    })

    local function eslint()
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
end
