local lint_status_ok, lint = pcall(require, "lint")
if not lint_status_ok then
    vim.notify("Plugin lint is missing")
    return
end

-- TODO: Add all linters
lint.linters_by_ft = {
    c = { "clangtidy", "cpplint" },
    cpp = { "clangtidy", "cpplint" },
    dockerfile = { "hadolint" },
    go = { "golangcilint" },
    javascript = { "eslint_d" },
    lua = { "luacheck" },
    markdown = { "markdownlint", "proselint" },
    nix = { "statix" },
    python = { "ruff" },
    sh = { "shellcheck" },
    typescript = { "eslint_d" },
    yaml = { "yamllint" },
}

-- use for codespell for all except bib and css
for ft, _ in pairs(lint.linters_by_ft) do
    if ft ~= "bib" and ft ~= "css" then
        table.insert(lint.linters_by_ft[ft], "codespell")
    end
end

-- TODO: Fix autocmd events to run linters on open file
-- Trigger linter automatically
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    callback = function()
        lint.try_lint()
    end,
})
