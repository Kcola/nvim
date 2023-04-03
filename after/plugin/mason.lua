local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local utils = require("telescope.utils")

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded", width = 100 })

vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", width = 100 })

vim.api.nvim_create_augroup("lsp_autocommands", {
    clear = false,
})

local register_autocommands = function()
    -- diagnostics hover autocommand
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = "lsp_autocommands",
        buffer = bufnr,
        callback = function()
            vim.diagnostic.open_float(nil, { focus = false })
        end,
    })
end

-- Setup mason so it can manage external tooling
require("mason").setup()

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.

    local nmap = function(keys, func, desc)
        if desc then
            desc = "LSP: " .. desc
        end

        vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
    end

    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>qf", vim.lsp.buf.code_action, "[C]ode [A]ction")

    nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
    nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
    nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
    nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
    -- See `:help K` for why this keymap
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

    -- Lesser used LSP functionality
    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
    nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    nmap("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")

    --register_autocommands()
end

-- Diagnostics UI
-- Code actions doesn't have a global handler so we need to roll our sleeves a bit
--------------------------------------------------------------------------------------------------

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
        width = 100,
    },
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Enable the following language servers
-- Feel free to add/remove any LSPs that you want here. They will automatically be installed
local servers = { "tsserver", "omnisharp", "eslint", "ltex" }

-- Ensure the servers above are installed
require("mason-lspconfig").setup({
    ensure_installed = servers,
})

-- nvim-cmp supports additional completion capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

for _, lsp in ipairs(servers) do
    require("lspconfig")[lsp].setup({
        on_attach = on_attach,
        capabilities = capabilities,
    })
end

-- Turn on lsp status information
require("fidget").setup()

-- Example custom configuration for lua
--
-- Make runtime files discoverable to the server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require("lspconfig").lua_ls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT)
                version = "LuaJIT",
                -- Setup your lua path
                path = runtime_path,
            },
            diagnostics = {
                globals = { "vim" },
            },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = { enable = false },
        },
    },
})

-- nvim-cmp setup
local cmp = require("cmp")
local luasnip = require("luasnip")

local kind_icons = {
    Text = "",
    Method = "m",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
}
cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
    },
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
            -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
                path = "[Path]",
            })[entry.source.name]
            return vim_item
        end,
    },
})

-- Telescipe UI select
-- Code actions doesn't have a global handler so we need to roll our sleeves a bit
--------------------------------------------------------------------------------------------------
vim.ui.select = function(_items, opts, on_choice)
    local items = {}
    local low_priority_items = {}

    for _, item in ipairs(_items) do
        local low_priority = string.find(string.lower((item[2] or {}).title or "") or "", "disable")
            and item[2].command == "NULL_LS_CODE_ACTION"

        if low_priority then
            table.insert(low_priority_items, item)
        else
            table.insert(items, item)
        end
    end

    items = vim.list_extend(items, low_priority_items)

    local topts = require("telescope.themes").get_cursor({
        initial_mode = "normal",
    })
    opts = opts or {}
    local prompt = vim.F.if_nil(opts.prompt, "Select one of")
    if prompt:sub(-1, -1) == ":" then
        prompt = prompt:sub(1, -2)
    end
    opts.format_item = vim.F.if_nil(opts.format_item, function(e)
        return tostring(e)
    end)

    local sopts = {}
    local indexed_items, widths = vim.F.if_nil(sopts.make_indexed, function(items_)
        local indexed_items = {}
        for idx, item in ipairs(items_) do
            table.insert(indexed_items, { idx = idx, text = item })
        end
        return indexed_items
    end)(items)
    local displayer = vim.F.if_nil(sopts.make_displayer, function() end)(widths)
    local make_display = vim.F.if_nil(sopts.make_display, function(_)
        return function(e)
            local x, _ = opts.format_item(e.value.text)
            return x
        end
    end)(displayer)
    local make_ordinal = vim.F.if_nil(sopts.make_ordinal, function(e)
        return opts.format_item(e.text)
    end)

    pickers
        .new(topts, {
            prompt_title = prompt,
            finder = finders.new_table({
                results = indexed_items,
                entry_maker = function(e)
                    return {
                        value = e,
                        display = make_display,
                        ordinal = make_ordinal(e),
                    }
                end,
            }),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local selection = action_state.get_selected_entry()
                    if selection == nil then
                        utils.__warn_no_selection("ui-select")
                        return
                    end
                    actions.close(prompt_bufnr)
                    on_choice(selection.value.text, selection.value.idx)
                end)
                return true
            end,
            sorter = conf.generic_sorter(topts),
        })
        :find()
end

-- Diagnostic keymaps
vim.keymap.set("n", "[g", function()
    vim.diagnostic.goto_prev()
end)
vim.keymap.set("n", "]g", function()
    vim.diagnostic.goto_next()
end)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)
