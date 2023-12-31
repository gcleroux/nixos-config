local conform_status_ok, conform = pcall(require, "conform")
if not conform_status_ok then
    vim.notify("Plugin conform is missing")
    return
end

-- TODO: Configure ruff to sort imports + install prettierd
conform.setup({
    formatters = {
        clang_format = {
            prepend_args = { "-style", "google" },
        },
    },
    formatters_by_ft = {
        -- Conform will run multiple formatters sequentially
        -- Use a sub-list to run only the first available formatter
        c = { "clang_format" },
        cpp = { "clang_format" },
        css = { "prettierd" },
        cuda = { "clang_format" },
        html = { "prettierd" },
        javascript = { "prettierd" },
        json = { "prettierd" },
        lua = { "stylua" },
        markdown = { "prettierd" },
        nix = { "nixfmt" },
        python = { "ruff_fix", "ruff_format" },
        sh = { "shfmt" },
        typescript = { "prettierd" },
        yaml = { "prettierd" },
    },
    format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
    },
})
