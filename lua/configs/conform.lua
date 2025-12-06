local options = {

    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },

    formatters_by_ft = {
        lua = { "stylua" },
        -- add more languages here:
        -- javascript = { "prettier" },
        -- python = { "black" },
        -- c = { "clang_format" },
    },
}

return options
