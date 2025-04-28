return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = {},
        ruff = {
          lint = {
            enable = false,
          },
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
          end,
        },
      },
    },
  },
}
