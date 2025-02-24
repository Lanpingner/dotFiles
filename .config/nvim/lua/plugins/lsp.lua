return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = {
          mason = false,
        },
        ruff = {
          mason = false,
        },
        bashls = {},
        clangd = {},
        cssls = {},
        eslint = {},
        stylelint_lsp = {},
        html = {},
        svelte = {},
        tsserver = {},
        marksman = {},
        lua_ls = {},
        -- FIXME: remove after uni
        sqlls = {},
        pyright = {
          on_attach = function(client, bufnr)
            -- Disable diagnostics (auto linting) from Pyright
            client.server_capabilities.diagnosticProvider = false

            -- Optionally disable other capabilities if needed
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            client.server_capabilities.documentHighlightProvider = false
            client.server_capabilities.documentSymbolProvider = false
            client.server_capabilities.hoverProvider = false
            client.server_capabilities.codeActionProvider = false
            client.server_capabilities.definitionProvider = false
          end,
        },
      },
    },
  },
}
