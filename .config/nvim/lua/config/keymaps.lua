local km = vim.keymap.set

-- Telescope
km("n", "<C-f-p>", require("telescope.builtin").live_grep, { desc = "[F]ind in file using Telescope" })
km("n", "<C-d>", require("telescope.builtin").lsp_document_symbols, { desc = "Telescope [D]ocument Symbols" })
km("n", "<C-f>", function()
  require("telescope.builtin").find_files(require("telescope.themes").get_dropdown({ previewer = false }))
end, { desc = "Telescope [f]ind file" })

-- Telescope Buffers
km({ "n", "i", "v" }, "<C-b>", require("telescope.builtin").buffers, { desc = "Telescope [b]uffers" })

-- move selected lines
km("v", "J", ":m '>+1<CR>gv=gv")
km("v", "K", ":m '<-2<CR>gv=gv")

-- diagnostics
km("n", "<leader>xx", vim.cmd.TroubleToggle, { desc = "TroubleToggle" })
km("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", { desc = "TroubleToggle [W]orkspace" })

-- buffers
km({ "n", "i", "v" }, "<A-l>", vim.cmd.bnext, { desc = "Switch to next Buffer" })
km({ "n", "i", "v" }, "<A-h>", vim.cmd.bprev, { desc = "Switch to prev Buffer" })
km("n", "q", function()
  vim.cmd("bw")
end, { desc = "Close Buffer" })

-- selection
km("n", "<C-a>", "ggVG")
km("v", "V", "j")

-- colors
km("n", "<leader>cg", vim.cmd.ColorizerToggle, { desc = "[C]olorizer" })
km("n", "<leader>cp", vim.cmd.PickColor, { desc = "[P]ick Color" })

-- generate docs
km("n", "<Leader>dg", require("neogen").generate, { desc = "Generate Docs" })

-- tmux
km({ "n", "i", "v" }, "<C-h>", vim.cmd.TmuxNavigateLeft)
km({ "n", "i", "v" }, "<C-j>", vim.cmd.TmuxNavigateDown)
km({ "n", "i", "v" }, "<C-k>", vim.cmd.TmuxNavigateUp)
km({ "n", "i", "v" }, "<C-l>", vim.cmd.TmuxNavigateRight)

-- tranparency
km("n", "<leader>o", function()
  vim.cmd("highlight Normal guibg=NONE")
  vim.cmd("highlight NonText guibg=NONE")
  vim.cmd("highlight NonText ctermbg=NONE")
  vim.cmd("highlight NonText ctermbg=NONE")
end)
