return {
  { "mason-org/mason-lspconfig.nvim", enabled = not vim.env.IS_NIX },
  { "mason-org/mason.nvim", enabled = not vim.env.IS_NIX },
}
