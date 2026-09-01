-- Customize Mason
-- Language servers and treesitter parsers mostly come from the community packs,
-- this list covers the extra formatters, linters and debuggers.

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- formatters
        "stylua",
        "gofumpt",
        "goimports",
        "shfmt",
        "prettier",
        "taplo",
        "sqlfluff",

        -- linters
        "shellcheck",
        "yamllint",
        "hadolint",
        "markdownlint-cli2",
        "eslint_d",
        "ruff",

        -- debuggers
        "delve",
        "debugpy",

        "tree-sitter-cli",
      },
    },
  },
}
