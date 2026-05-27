local ok, textobjects = pcall(require, "nvim-treesitter-textobjects")
if not ok then
    vim.notify("Plugin nvim-treesitter-textobjects is missing")
    return
end

textobjects.setup({
    select = {
        lookahead = true,
        include_surrounding_whitespace = false,
    },
    move = {
        set_jumps = true,
    },
    lsp_interop = {
        border = "none",
        floating_preview_opts = {},
    },
})

-- Select textobjects
vim.keymap.set({ "x", "o" }, "af", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "if", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ac", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "ic", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end)

vim.keymap.set({ "x", "o" }, "as", function()
    require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
end)

-- Move textobjects
local move = require("nvim-treesitter-textobjects.move")

vim.keymap.set({ "n", "x", "o" }, "]f", function()
    move.goto_next_start("@function.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]F", function()
    move.goto_next_end("@function.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[f", function()
    move.goto_previous_start("@function.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[F", function()
    move.goto_previous_end("@function.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]c", function()
    move.goto_next_start("@class.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]C", function()
    move.goto_next_end("@class.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[c", function()
    move.goto_previous_start("@class.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "[C", function()
    move.goto_previous_end("@class.outer", "textobjects")
end)

vim.keymap.set({ "n", "x", "o" }, "]s", function()
    move.goto_next_start("@local.scope", "locals")
end)

vim.keymap.set({ "n", "x", "o" }, "[s", function()
    move.goto_previous_start("@local.scope", "locals")
end)
