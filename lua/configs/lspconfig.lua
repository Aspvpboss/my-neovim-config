require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "clangd", "stylua" }
vim.lsp.enable(servers)

-- to configure lsps further read :h vim.lsp.config
