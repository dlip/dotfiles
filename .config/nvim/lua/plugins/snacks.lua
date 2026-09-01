---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = function(_, opts) opts.dashboard = { enabled = false } end,
}
