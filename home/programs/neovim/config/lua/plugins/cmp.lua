local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
    return
end

local luasnip_status_ok, luasnip = pcall(require, "luasnip")
if not luasnip_status_ok then
    vim.notify("Plugin luasnip is missing")
    return
end

-- From: https://github.com/VonHeikemen/lsp-zero.nvim/blob/d388e2b71834c826e61a3eba48caec53d7602510/lua/lsp-zero/cmp-mapping.lua#L221-L265
---If the completion menu is visible it will navigate to the next item in
---the list. If cursor is on top of the trigger of a snippet it'll expand
---it. If the cursor can jump to a luasnip placeholder, it moves to it.
---If the cursor is in the middle of a word that doesn't trigger a snippet
---it displays the completion menu. Else, it uses the fallback.
local function luasnip_supertab(select_opts)
    return cmp.mapping(function(fallback)
        local col = vim.fn.col(".") - 1

        if cmp.visible() then
            cmp.select_next_item(select_opts)
        elseif luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
        elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
            fallback()
        else
            cmp.complete()
        end
    end, { "i", "s" })
end

---If the completion menu is visible it will navigate to previous item in the
---list. If the cursor can navigate to a previous snippet placeholder, it
---moves to it. Else, it uses the fallback.
local function luasnip_shift_supertab(select_opts)
    return cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item(select_opts)
        elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end, { "i", "s" })
end

local kind_icons = {
    Text = "",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰇽",
    Variable = "󰂡",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "󰅲",
}

cmp.setup({
    enabled = function()
        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt" or require("cmp_dap").is_dap_buffer()
    end,
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    mapping = {
        ["<Tab>"] = luasnip_supertab(),
        ["<S-Tab>"] = luasnip_shift_supertab(),
        ["<CR>"] = cmp.mapping.confirm({ select = false }),

        ["<C-a>"] = cmp.mapping.complete(), -- Every cmp entry
        ["<C-e>"] = cmp.mapping.abort(),

        ["<C-j>"] = cmp.mapping.scroll_docs(4),
        ["<C-k>"] = cmp.mapping.scroll_docs(-4),
    },
    formatting = {
        format = function(entry, vim_item)
            -- Kind icons
            vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind], vim_item.kind)
            vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
                path = "[Path]",
                emoji = "", -- No need for emoji menu identifier
            })[entry.source.name]
            return vim_item
        end,
    },
    filetype = {
        { "dap-repl" },
        { "dapui_watches" },
        { "dapui_hover" },
        sources = {
            name = "dap",
        },
    },
    sources = {
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
        { name = "emoji" },
    },
    windowdocumentation = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    },
    experimental = {
        ghost_text = false,
    },
})
