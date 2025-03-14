require("fzf-lua").setup({
    winopts = { preview = { default = "bat" } },
    manpages = { previewer = "man_native" },
    helptags = { previewer = "help_native" },
    lsp = { code_actions = { previewer = "codeaction_native" } },
    tags = { previewer = "bat" },
    btags = { previewer = "bat" },
})

vim.api.nvim_set_keymap("n", "<leader>f", "<cmd>FzfLua files<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>t", "<cmd>FzfLua live_grep<CR>", { noremap = true, silent = true })
