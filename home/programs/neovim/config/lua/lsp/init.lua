-- Set up handlers
require("lsp.handlers").setup()

-- Formatters and linters
-- require("lsp.null-ls") -- Must be loaded after mason-null-ls
require("lsp.linter")
require("lsp.formatter")
require("lsp.code-actions")
-- TODO: Add hover

-- Specific go plugin
require("lsp.go")

-- LSP config
require("lsp.lspconfig") -- Always load lspconfig at the end
