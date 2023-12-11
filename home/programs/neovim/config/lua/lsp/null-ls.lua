local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/code_actions
local code_actions = null_ls.builtins.code_actions

-- Using shared capabilities from handlers
local on_attach = require("lsp.handlers").on_attach

null_ls.setup({
    debug = true,
    sources = {
        -- Editor wide linter/formatting
        diagnostics.codespell,

        -- Python tools
        formatting.isort,
        formatting.black.with({ extra_args = { "--fast", "--line-length", "88" } }),
        diagnostics.flake8.with({ extra_args = { "--max-line-length", "88" } }),
        diagnostics.pylint.with({ extra_args = { "--disable", "F0401,C0301" } }),

        -- Lua tools
        formatting.stylua,
        diagnostics.luacheck,

        -- C/C++/CS/CUDA tools
        formatting.clang_format.with({
            -- Needs a .clang_format file otherwise the modifications get stuck in output to stdin
            extra_args = { "-style=file:" .. "$HOME/.clang-format" },
        }),
        diagnostics.cpplint,

        -- Go tools
        diagnostics.golangci_lint,
        -- Don't nee this since it is integrated in gopls
        -- formatting.gofmt,
        -- formatting.goimports,
        -- Replaced with gopher.nvim
        -- code_actions.gomodifytags,
        -- code_actions.impl,

        -- Markdown tools
        -- formatting.markdown_toc,     -- No native package in NixOS
        formatting.cbfmt,
        diagnostics.markdownlint,

        -- Shell tools
        formatting.shfmt.with({ extra_args = { "--indent", "4" } }), -- Tab to space
        diagnostics.shellcheck,
        code_actions.shellcheck,

        -- Dockerfile tools
        diagnostics.hadolint,

        -- JS, TS, JSON, YAML, HTML, CSS, Mardown, etc. tools
        formatting.prettier,
        diagnostics.yamllint,

        -- Nix tools
        formatting.nixfmt,
        diagnostics.statix,
        diagnostics.deadnix,
        code_actions.statix,
    },
    -- you can reuse a shared lspconfig on_attach callback here
    on_attach = on_attach,
})
