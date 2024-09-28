{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.home = {
    name = mkOption {
      type = types.str;
      default = "Dane Lipscombe";
    };
    email = mkOption {
      type = types.str;
      default = "danelipscombe@gmail.com";
    };
  };

  imports = [
    ./files
    ./fonts.nix
    ./lsp.nix
    ./packages.nix
    ./readline
    ./session.nix
    ./version.nix
  ];
}
