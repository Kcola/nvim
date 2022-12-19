local entry_display = require("telescope.pickers.entry_display")
local config = CONFIG.telescope;
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
    local filename = vim.fn.fnamemodify(entry.filename, ":h:t") .. "/" .. vim.fn.fnamemodify(entry.filename, ":t")

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
-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  defaults = {
    path_display = { "truncate" },
    file_ignore_patterns = { "node_modules", "lib" },
    prompt_prefix = " >",
    color_devicons = true,

    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
      },
    },
  },
pickers = {
    live_grep = {
      search_dirs = config,
      additional_args = function() end,
      mappings = {
        i = {
          ["<c-p>"] = function()
            print(vim.fn.getcwd())
          end,
        },
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
}

pcall(require('telescope').load_extension, 'fzf')

local search_vim_config = function()
  require("telescope.builtin").find_files({
    prompt_title = "<VimRc >",
    cwd = "~/.config",
    path_display = { "truncate" },
  })
end
vim.keymap.set("n", "<leader>vrc", search_vim_config, {desc = "Search dotfiles"})
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()

  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })

vim.keymap.set('n', '<c-p>', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
