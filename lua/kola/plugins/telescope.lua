return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-live-grep-args.nvim" },
    config = function()
        local pickers = require("telescope.pickers")
        local entry_display = require("telescope.pickers.entry_display")
        local config = CONFIG.telescope
        local utils = require("telescope.utils")
        local strings = require("plenary.strings")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local finders = require("telescope.finders")
        local action_state = require("telescope.actions.state")
        local fb_actions = require("telescope").extensions.file_browser.actions

        local checkout = function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection == nil then
                utils.__warn_no_selection("actions.git_switch_branch")
                return
            end
            actions.close(prompt_bufnr)
            local pattern = "^refs/remotes/%w+/"
            local branch = selection.value
            if string.match(selection.refname, pattern) then
                branch = string.gsub(selection.refname, pattern, "")
            end
            vim.cmd("G checkout " .. branch)
        end

        local delete_branch = function()
            local selection = action_state.get_selected_entry()
            local confirmation = vim.fn.confirm("Delete " .. selection.name, "&Yes\n&No")
            if confirmation == 1 then
                vim.cmd("G branch -D " .. selection.value)
            end
        end

        local git_branches = function()
            local format = "%(HEAD)"
                .. "%(refname)"
                .. "%(authorname)"
                .. "%(upstream:lstrip=2)"
                .. "%(committerdate:relative)"
            local output = utils.get_os_command_output({ "git", "for-each-ref", "--perl", "--format", format })

            local results = {}
            local widths = {
                name = 0,
                authorname = 0,
                upstream = 0,
                committerdate = 0,
            }
            local unescape_single_quote = function(v)
                return string.gsub(v, "\\([\\'])", "%1")
            end
            local parse_line = function(line)
                local fields = vim.split(string.sub(line, 2, -2), "''", true)
                local entry = {
                    head = fields[1],
                    refname = unescape_single_quote(fields[2]),
                    authorname = unescape_single_quote(fields[3]),
                    upstream = unescape_single_quote(fields[4]),
                    committerdate = fields[5],
                }
                local prefix
                if vim.startswith(entry.refname, "refs/remotes/") then
                    prefix = "refs/remotes/"
                elseif vim.startswith(entry.refname, "refs/heads/") then
                    prefix = "refs/heads/"
                else
                    return
                end
                local index = 1
                if entry.head ~= "*" then
                    index = #results + 1
                end

                entry.name = string.sub(entry.refname, string.len(prefix) + 1)
                for key, value in pairs(widths) do
                    widths[key] = math.max(value, strings.strdisplaywidth(entry[key] or ""))
                end
                if string.len(entry.upstream) > 0 then
                    widths.upstream_indicator = 2
                end
                table.insert(results, index, entry)
            end
            for _, line in ipairs(output) do
                parse_line(line)
            end
            if #results == 0 then
                return
            end

            local displayer = entry_display.create({
                separator = " ",
                items = {
                    { width = 1 },
                    { width = 70 },
                    { width = 20 },
                    { width = widths.upstream_indicator },
                    { width = widths.committerdate },
                },
            })

            local make_display = function(entry)
                return displayer({
                    { entry.head },
                    { entry.name, "TelescopeResultsIdentifier" },
                    { entry.authorname, "TelescopePreviewUser" },
                    { string.len(entry.upstream) > 0 and "" or "" },
                    { entry.committerdate, "TelescopePreviewDate" },
                })
            end

            pickers
                .new({}, {
                    prompt_title = "Git Branches",
                    finder = finders.new_table({
                        results = results,
                        entry_maker = function(entry)
                            entry.value = entry.name
                            entry.ordinal = entry.name .. " " .. entry.authorname
                            entry.display = make_display
                            return entry
                        end,
                    }),
                    previewer = false,
                    layout_strategy = "vertical",
                    layout_config = { prompt_position = "top", width = 0.4, height = 0.4 },
                    sorter = conf.file_sorter(),
                    attach_mappings = function(_, map)
                        actions.select_default:replace(checkout)
                        map("i", "<c-t>", actions.git_track_branch)
                        map("n", "<c-t>", actions.git_track_branch)

                        map("i", "<c-r>", actions.git_rebase_branch)
                        map("n", "<c-r>", actions.git_rebase_branch)

                        map("i", "<c-a>", actions.git_create_branch)
                        map("n", "<c-a>", actions.git_create_branch)

                        map("i", "<c-s>", actions.git_switch_branch)
                        map("n", "<c-s>", actions.git_switch_branch)

                        map("i", "<c-d>", delete_branch)
                        map("n", "<c-d>", actions.git_delete_branch)

                        map("i", "<c-y>", actions.git_merge_branch)
                        map("n", "<c-y>", actions.git_merge_branch)
                        return true
                    end,
                })
                :find()
        end

        local entry_from_quickfix = function(opts)
            opts = opts or {}

            local displayer = entry_display.create({
                separator = "▏",
                items = {
                    { width = 8 },
                    { remaining = true },
                },
            })

            local make_display = function(entry)
                local filename = vim.fn.fnamemodify(entry.filename, ":h:t")
                    .. "/"
                    .. vim.fn.fnamemodify(entry.filename, ":t")

                local line_info = { table.concat({ entry.lnum, entry.col }, ":"), "TelescopeResultsLineNr" }

                return displayer({
                    line_info,
                    filename,
                })
            end
            return function(entry)
                local filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr)

                return {
                    valid = true,

                    value = entry,
                    ordinal = (not opts.ignore_filename and filename or "") .. " " .. entry.text,
                    display = make_display,

                    bufnr = entry.bufnr,
                    filename = filename,
                    lnum = entry.lnum,
                    col = entry.col,
                    text = entry.text,
                    start = entry.start,
                    finish = entry.finish,
                }
            end
        end

        local ignoreFiles = { "node_modules", "lib", ".git", ".*exe", ".*dll", ".*/nvim/lazy.nvim", "^locales" }
        local lga_actions = require("telescope-live-grep-args.actions")

        -- [[ Configure Telescope ]]
        -- See `:help telescope` and `:help telescope.setup()`
        require("telescope").setup({

            defaults = {
                file_sorter = require("telescope.sorters").get_fzy_sorter,
                path_display = { "truncate" },
                prompt_prefix = " >",
                color_devicons = true,
                mappings = {
                    n = {
                        ["<leader>s"] = actions.select_vertical,
                    },
                    i = {
                        ["<C-u>"] = false,
                        ["<C-d>"] = false,
                        ["<leader>s"] = actions.select_vertical,
                    },
                },
            },
            pickers = {
                find_files = {
                    file_ignore_patterns = ignoreFiles,
                    hidden = true,
                },
                live_grep = {
                    search_dirs = config,
                    file_ignore_patterns = ignoreFiles,
                    additional_args = function() end,
                    mappings = {
                        i = {
                            ["<c-p>"] = function()
                                print(vim.fn.getcwd())
                            end,
                        },
                    },
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "--hidden",
                    },
                },
                buffers = {
                    file_ignore_patterns = {},
                    mappings = {
                        n = {
                            ["<c-d>"] = "delete_buffer",
                        },
                        i = {
                            ["<c-d>"] = "delete_buffer",
                        },
                    },
                },
                grep_string = {
                    file_ignore_patterns = ignoreFiles,
                    search_dirs = config,
                },
                git_branches = {
                    layout_strategy = "center",
                },
                lsp_definitions = {
                    initial_mode = "normal",
                    entry_maker = entry_from_quickfix(),
                },
                lsp_type_definitions = {
                    initial_mode = "normal",
                    entry_maker = entry_from_quickfix(),
                },
                lsp_implementations = {
                    initial_mode = "normal",
                    entry_maker = entry_from_quickfix(),
                },
                lsp_references = {
                    initial_mode = "normal",
                    entry_maker = entry_from_quickfix(),
                },
            },
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
                live_grep_args = {
                    auto_quoting = true, -- enable/disable auto-quoting
                    -- define mappings, e.g.
                    mappings = { -- extend mappings
                        i = {
                            ["<C-k>"] = lga_actions.quote_prompt(),
                            ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                            -- freeze the current list and start a fuzzy search in the frozen list
                            ["<C-space>"] = actions.to_fuzzy_refine,
                        },
                    },
                    -- ... also accepts theme settings, for example:
                    -- theme = "dropdown", -- use dropdown theme
                    -- theme = { }, -- use own theme spec
                    -- layout_config = { mirror=true }, -- mirror preview pane
                },
            },
        })

        require("telescope").load_extension("file_browser")
        require("telescope").load_extension("live_grep_args")

        pcall(require("telescope").load_extension, "fzf")

        local search_vim_config = function()
            require("telescope.builtin").find_files({
                prompt_title = "<VimRc >",
                cwd = IS_WINDOWS and os.getenv("HOMEPATH") .. "\\dotfiles\\.config\\" or "~/.config",
                path_display = { "truncate" },
            })
        end
        vim.keymap.set("n", "<leader>vrc", search_vim_config, { desc = "Search dotfiles" })
        vim.keymap.set("n", "<leader>gb", git_branches, { desc = "Show git branches" })
        vim.keymap.set(
            "n",
            "<leader>?",
            require("telescope.builtin").oldfiles,
            { desc = "[?] Find recently opened files" }
        )
        vim.keymap.set("n", "<leader><space>", function()
            require("persistence").load()
            require("telescope.builtin").buffers()
        end, { desc = "[ ] Find existing buffers" })
        vim.keymap.set("n", "<leader>/", function()
            require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
                winblend = 10,
                previewer = false,
            }))
        end, { desc = "[/] Fuzzily search in current buffer]" })

        vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
        vim.keymap.set(
            "n",
            "<leader>sw",
            require("telescope.builtin").grep_string,
            { desc = "[S]earch current [W]ord" }
        )
        vim.keymap.set(
            "n",
            "<leader>ff",
            require("telescope").extensions.live_grep_args.live_grep_args,
            { desc = "[S]earch by [G]rep" }
        )
        vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
        vim.keymap.set("n", "<c-b>", require("telescope.builtin").buffers, { desc = "[S]earch [B]uffers" })
        vim.api.nvim_set_keymap(
            "n",
            "<leader>t",
            ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
            { noremap = true }
        )
    end,
    keys = { {
        "<c-p>",
        ":lua require('telescope.builtin').find_files()<CR>",
    } },
}
