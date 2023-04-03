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
                return vim.fn.expand("%:p")
            end,
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
    },
})
