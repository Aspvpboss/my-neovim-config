require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "clangd", "zls", "asm-lsp" }
vim.lsp.enable(servers)

-- to configure lsps further read :h vim.lsp.config
