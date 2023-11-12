local utils = require("kola.utils")
local function view_commit()
    local line = vim.fn.getline(".")
    vim.cmd("DiffviewOpen " .. line:firstword() .. "^!")
end

vim.api.nvim_create_user_command("DeleteQuickFixListEntries", function()
    vim.diagnostic.setqflist({ open = false })
    local qflist = vim.fn.getqflist()

    -- delete all buffer lines that are in the quickfix list
    -- and adjust the buffer line numbers as we go
    for i = #vim.api.nvim_buf_get_lines(0, 0, -1, false), 1, -1 do
        if
            vim.tbl_contains(
                vim.tbl_map(function(item)
                    return item.lnum
                end, qflist),
                i
            )
        then
            vim.api.nvim_buf_set_lines(0, i - 1, i, false, {})
        end
    end
end, {
    nargs = 0,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "git",
    callback = function()
        vim.keymap.set("n", "<cr>", view_commit, { noremap = true, silent = true, buffer = true })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "git",
    command = "nnoremap <buffer><silent> q <cmd>q<cr>",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "fugitiveblame",
    callback = function()
        vim.keymap.set("n", "<cr>", view_commit, { noremap = true, silent = true, buffer = true })
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "fugitiveblame",
    command = "nnoremap <buffer><silent> q <cmd>q<cr>",
})

local job = nil

vim.api.nvim_create_user_command("StartLiveServer", function(opts)
    -- start live server
    job = vim.fn.jobstart("live-server " .. opts.args, {
        on_stdout = function(_, data)
            P(data[1])
        end,
    })
    print("Live server started")
end, {
    nargs = 1,
})

vim.api.nvim_create_user_command("StopLiveServer", function()
    vim.fn.jobstop(job)
    print("Live server stopped")
end, {})

vim.api.nvim_create_user_command("Jest", function()
    print(utils.get_jest_nearest_test())
end, {})
