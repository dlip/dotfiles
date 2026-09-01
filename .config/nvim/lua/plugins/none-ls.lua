-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"

    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      null_ls.builtins.formatting.shfmt.with { extra_args = { "-i", "2", "-ci" } },
      null_ls.builtins.formatting.alejandra,
      null_ls.builtins.formatting.sqlfluff.with { extra_args = { "--dialect", "postgres" } },
      null_ls.builtins.diagnostics.yamllint,
      null_ls.builtins.diagnostics.hadolint,
    })
  end,
}
