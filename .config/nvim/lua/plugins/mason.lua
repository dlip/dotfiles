-- Customize Mason
-- Language servers and treesitter parsers mostly come from the community packs,
-- this list covers the extra formatters, linters and debuggers.

if vim.env.IS_NIX == "true" then
  return {
    { "mason-org/mason.nvim", enabled = false },
    { "mason-org/mason-lspconfig.nvim", enabled = false },
    { "WhoIsSethDaniel/mason-tool-installer.nvim", enabled = false },
    { "jay-babu/mason-nvim-dap.nvim", enabled = false },
    { "jay-babu/mason-null-ls.nvim", enabled = false },
  }
end

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
