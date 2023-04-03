IS_WINDOWS = vim.fn.has("win32") == 1

local configs_found, configs = pcall(function()
    return vim.fn.json_decode(vim.fn.readfile(vim.fn.expand(CONFIG_PATH)))
end)

if not configs_found then
    CONFIG = {}
    return
end

local getProject = function()
    return vim.fn.fnamemodify(vim.fn.finddir(".git/..", ";"), ":p:h:t")
end
CONFIG = configs[getProject()]
