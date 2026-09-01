-- Cross-boundary window navigation: move between Neovim splits, then hand off
-- to the surrounding multiplexer (herdr, falling back to tmux) at a split edge.

local function nav(wincmd, dir)
  local prev = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. wincmd)
  if vim.api.nvim_get_current_win() ~= prev then return end

  if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
    local herdr = vim.env.HERDR_BIN_PATH
    if herdr == nil or herdr == "" then herdr = "herdr" end
    vim.fn.system { herdr, "pane", "focus", "--direction", dir, "--current" }
  elseif vim.env.TMUX and vim.env.TMUX ~= "" then
    local tmux = { left = "Left", down = "Down", up = "Up", right = "Right" }
    pcall(vim.cmd, "TmuxNavigate" .. tmux[dir])
  end
end

local function mapping(wincmd, dir)
  return { function() nav(wincmd, dir) end, desc = "Navigate " .. dir .. " (vim/herdr)", silent = true }
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<C-Left>"] = mapping("h", "left"),
        ["<C-Down>"] = mapping("j", "down"),
        ["<C-Up>"] = mapping("k", "up"),
        ["<C-Right>"] = mapping("l", "right"),
      },
    },
  },
}
