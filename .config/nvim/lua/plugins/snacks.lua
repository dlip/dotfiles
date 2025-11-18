return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>a",
      function()
        Snacks.picker.smart({
          multi = { "buffers", "git_files" },
        })
      end,
      desc = "Smart file picker",
    },
    {
      "<leader>fr",
      function()
        Snacks.picker.recent({ filter = { cwd = true } })
      end,
      desc = "Recent files",
    },
  },
}
