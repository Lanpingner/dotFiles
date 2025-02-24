return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      filesystem = {
        filtered_items = {
          visible = false, -- hide filtered items on open
          hide_gitignored = true,
          hide_dotfiles = false,
          hide_by_name = {
            ".github",
            ".gitignore",
            "package-lock.json",
            ".changeset",
            ".prettierrc.json",
          },
          never_show = { ".git" },
        },
      },
      ensure_installed = {
        "bash",
        "c",
        "cpp",

        "html",
        "javascript",
        "json",
        "yaml",
        "svelte",
        "scss",
        "css",
        "tsx",
        "typescript",

        "lua",
        "luadoc",
        "luap",

        "markdown",
        "markdown_inline",

        "python",
        "query",
        "regex",
        "vim",
        "vimdoc",

        -- FIXME: remove after uni
        "java",
        "sql",
      },
    },
  },
}
