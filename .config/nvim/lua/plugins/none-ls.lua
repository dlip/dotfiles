-- Customize None-ls sources
-- NOTE: alejandra is not installed via Mason (its registry entry builds from
-- cargo), install it with `brew install alejandra` instead.

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require "null-ls"

    local sources = {
      null_ls.builtins.formatting.shfmt.with { extra_args = { "-i", "2", "-ci" } },
      null_ls.builtins.formatting.sqlfluff.with { extra_args = { "--dialect", "postgres" } },
      null_ls.builtins.diagnostics.yamllint,
      null_ls.builtins.diagnostics.hadolint,
    }

    if vim.fn.executable "alejandra" == 1 then
      table.insert(sources, null_ls.builtins.formatting.alejandra)
    end

    opts.sources = require("astrocore").list_insert_unique(opts.sources, sources)
  end,
}
