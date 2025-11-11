-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set
map("n", "<cr>", "<cmd>:wa<cr>", { desc = "Write all", remap = true })
map("x", "y", "y`]", { desc = "Yank without moving cursor", remap = true })
map("x", "p", "P", { desc = "Paste without yank", remap = true })
-- map("n", "x", '"_x', { desc = "Delete without yank", remap = true })
map("n", "<bs>", '"_X', { desc = "Backspace without yank", remap = true })
map("n", "ga", "<c-6>", { desc = "Open alternate file", remap = true })
map("n", "U", "<c-r>", { desc = "Redo", remap = true })
-- map("n", "<leader>a", "<cmd>Telescope frecency workspace=CWD<cr>", { desc = "Telescope frecency" })
map("n", "<leader>y", "<cmd>let @+=expand('%').':'.line('.')<CR>", { desc = "Yank relative filename with line" })
map("n", "<leader>Y", "<cmd>let @+=expand('%:p')<CR>", { desc = "Yank absolute filename" })
map("n", "<leader>r", LazyVim.pick("live_grep"), { desc = "Grep (Root Dir)" })
map("n", "<leader>gC", "<cmd>Telescope git_bcommits<Cr>", { desc = "Buffer commits" })
map("n", "<leader>gi", "<cmd>DiffviewFileHistory<Cr>", { desc = "Diffview history" })
map("n", "<leader>gI", "<cmd>DiffviewFileHistory %<Cr>", { desc = "Diffview history (buffer)" })
map(
  "n",
  "<C-Left>",
  require("nvim-tmux-navigation").NvimTmuxNavigateLeft,
  { desc = "NvimTmuxNavigateLeft", remap = true }
)
map(
  "n",
  "<C-Down>",
  require("nvim-tmux-navigation").NvimTmuxNavigateDown,
  { desc = "NvimTmuxNavigateDown", remap = true }
)
map("n", "<C-Up>", require("nvim-tmux-navigation").NvimTmuxNavigateUp, { desc = "NvimTmuxNavigateUp", remap = true })
map(
  "n",
  "<C-Right>",
  require("nvim-tmux-navigation").NvimTmuxNavigateRight,
  { desc = "NvimTmuxNavigateRight", remap = true }
)
