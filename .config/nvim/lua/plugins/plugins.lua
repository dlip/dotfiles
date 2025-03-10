return {
  { "williamboman/mason-lspconfig.nvim", enabled = not vim.env.IS_NIX },
  { "williamboman/mason.nvim", enabled = not vim.env.IS_NIX },
  { "alexghergh/nvim-tmux-navigation" },
  {
    "nvim-neotest/neotest",
    opts = {
      adapters = {
        require("neotest-python")({
          runner = "django",
          args = { "--log-level", "DEBUG" },
          python = ".direnv/python-3.11/bin/python",
        }),
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      ---@type lspconfig.options
      servers = {
        pyright = {
          settings = {
            pyright = {
              -- Using Ruff's import organizer
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                -- Ignore all files for analysis to exclusively use Ruff for linting
                ignore = { "*" },
              },
            },
          },
        },
        ruff = {},
        nushell = {},
      },
      ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
      setup = {},
    },
  },
  {
    "nvim-telescope/telescope-frecency.nvim",
    config = function()
      require("telescope").load_extension("frecency")
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },
    cmd = { "DiffviewFileHistory" },
    keys = {
      {
        "<leader>gv",
        function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end,
        desc = "Toggle Diffview window",
      },
    },
  },
}
