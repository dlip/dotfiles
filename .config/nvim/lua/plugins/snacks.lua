return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>fr",
      function()
        Snacks.picker.recent({ filter = { cwd = true } })
      end,
      desc = "Recent",
    },
  },
}
