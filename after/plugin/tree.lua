local fb_actions = require("telescope").extensions.file_browser.actions

-- You don't need to set any of these options.
-- IMPORTANT!: this is only a showcase of how you can set default options!
require("telescope").setup({
    extensions = {
        file_browser = {
            hijack_netrw = true,
            initial_mode = "normal",
            file_ignore_patterns = {},
            previewer = false,
            layout_strategy = "vertical",
            layout_config = { prompt_position = "top", width = 0.5, height = 0.5 },
            mappings = {
                ["i"] = {},
                ["n"] = {
                    ["a"] = fb_actions.create,
                    ["y"] = fb_actions.copy,
                    ["d"] = fb_actions.remove,
                    ["r"] = fb_actions.rename,
                    ["H"] = fb_actions.toggle_hidden,
                    ["-"] = fb_actions.goto_parent_dir,
                },
            },
        },
    },
})
-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
require("telescope").load_extension("file_browser")
