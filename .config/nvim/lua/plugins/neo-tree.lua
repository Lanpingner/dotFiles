return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>e", "<Cmd>Neotree focus<CR>", desc = "Explorer NeoTree", remap = true },
    },
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

      window = {
        mappings = {
          ["<space>"] = "none",
          ["l"] = "open",
          ["h"] = "close_all_subnodes",
          ["L"] = "open_vsplit",
        },
      },
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
      },
    },
  },
}
