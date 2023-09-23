return {
    "nvim-lualine/lualine.nvim",
    config = function()
        require("lualine").setup({
            options = {
                icons_enabled = false,
                theme = "darkplus",
                component_separators = "|",
                section_separators = "",
            },
            tabline = {
                lualine_a = {
                    function()
                        local path = vim.fn.expand("%:p")
                        --replace home directory with ~
                        path = path:gsub(vim.env.HOME, "~")
                        return path
                    end,
                },
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
        })
    end,
}
