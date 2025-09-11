{ pkgs, ... }:
let
  extraPackages =
      [
      ];
in
{
  home.packages =
    with pkgs;
    [
      # alejandra # nix
      # codespell
      gh-markdown-preview
      gopls # golang
      # golangci-lint
      # haskellPackages.haskell-language-server
      markdownlint-cli2
      marksman # markdown
      # myNodePackages."@prisma/language-server"
      nil
      nixfmt-rfc-style
      # nodePackages.bash-language-server
      # nodePackages.dockerfile-language-server-nodejs
      # nodePackages.eslint_d
      # nodePackages.intelephense # php
      # nodePackages.prettier
      # nodePackages.prettier_d_slim
      # nodePackages.typescript-language-server
      # nodePackages.vim-language-server
      # nodePackages.yaml-language-server
      # openscad-lsp
      prettier
      # proselint
      pyright # python
      # python311Packages.black
      # python311Packages.python-lsp-server
      # racket-minimal # requires `raco pkg install fmt`
      ruff # python
      rust-analyzer # rust
      # rustfmt
      shfmt
      # solang
      stylua
      lua-language-server
      # taplo
      # terraform-ls
      # tree-sitter
      # vale
      # vim-vint
      # yamllint
    ]
    ++ extraPackages;
}
