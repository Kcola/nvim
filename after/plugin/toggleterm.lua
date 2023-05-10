local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
    return
end

local powershell_options = {
    shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
    shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
    shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
    shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
    shellquote = "",
    shellxquote = "",
}

if IS_WINDOWS then
    for option, value in pairs(powershell_options) do
        vim.opt[option] = value
    end
end

local vertical_width = vim.o.columns * 0.35

local get_package_root = require("kola.utils").get_package_root
local get_jest_nearest_test = require("kola.utils").get_jest_nearest_test
local convert_windows_path = require("kola.utils").convert_windows_path

toggleterm.setup({
    size = function(term)
        if term.direction == "vertical" then
            return vertical_width
        elseif term.direction == "horizontal" then
            return 15
        end
    end,
    open_mapping = [[<c-\>]],
    hide_numbers = true,
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = true,
    persist_size = true,
    direction = "float",
    close_on_exit = true,
    shell = vim.o.shell,
    float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
            border = "Normal",
            background = "Normal",
        },
        width = function()
            return math.ceil(vim.o.columns * 0.8)
        end,
        height = function()
            return math.ceil(vim.o.lines * 0.8)
        end,
    },
})

local Terminal = require("toggleterm.terminal").Terminal

local vert = Terminal:new({
    direction = "vertical",
    hidden = true,
})

local try_close_vert = function()
    if vert:is_open() then
        vert:close()
    end
end

vim.api.nvim_create_autocmd("BufDelete", {
    callback = try_close_vert,
})

local function vert_toggle()
    vert:toggle(vertical_width)
end

local function vert_test()
    local custom_jest_command = nil
    if PROJECT_NAME == "power-platform-ux" then
        if IS_WINDOWS then
            custom_jest_command = 'node "'
                .. vim.fn.finddir("packages", ";")
                .. "/build-scripts/node_modules/jest/bin/jest.js"
                .. "\" --runInBand -t '"
        else
            custom_jest_command = "node "
                .. vim.fn.finddir("packages", ";")
                .. "/build-scripts/node_modules/jest/bin/jest.js"
                .. " --runInBand -t '"
        end
    end

    local current_buffer = vim.fn.expand("%:p")
    local jest_nearest_test = get_jest_nearest_test()
    local package_root = get_package_root()

    if not jest_nearest_test then
        return
    end

    vert:change_dir(package_root)

    if IS_WINDOWS then
        vert:send(
            (custom_jest_command or 'node "$(npm root)/jest/bin/jest.js" -t \'')
                .. jest_nearest_test
                .. "' "
                .. convert_windows_path(current_buffer)
        )
    else
        vert:send(
            (custom_jest_command or "node (npm root)/jest/bin/jest.js -- -t '")
                .. jest_nearest_test
                .. "' -- "
                .. current_buffer
        )
    end
end

local function vert_e2e_test()
    local config = CONFIG
    vert:send("cd " .. get_package_root())
    local current_buffer = vim.fn.expand("%:p")
    local env = config.playwright or {}

    local set_env_string = ""
    for key, value in pairs(env) do
        set_env_string = set_env_string .. key .. "=" .. value .. " "
    end

    local command = set_env_string .. "playwright test " .. current_buffer

    vert:send(command)
end

vim.keymap.set("n", "<F12>", vert_toggle)
vim.keymap.set("n", "<leader>J", vert_test)
vim.keymap.set("n", "<leader>E2E", vert_e2e_test)

local function set_terminal_keymaps()
    local opts = { noremap = true }
    vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
    vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
    vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
    vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
    vim.keymap.set("t", "<F12>", vert_toggle, opts)
end

local augroup = vim.api.nvim_create_augroup("ToggleTerm", { clear = true })
local toggleterm_pattern = { "term://*#toggleterm#*", "term://*::toggleterm::*" }

vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup,
    pattern = toggleterm_pattern,
    callback = set_terminal_keymaps,
})
