{
  config,
  pkgs,
  ...
}: {
  home.file = {
    "${config.xdg.configHome}/networkmanager-dmenu".source = ./networkmanager-dmenu;
    "${config.xdg.configHome}/dlv/config.yml".source = ./delve.yaml;
    "${config.xdg.configHome}/warpd/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixconfig/home/files/warpd.yaml";
    # "${config.home.homeDirectory}/.xprofile".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixconfig/home/files/xprofile";

    "${config.home.homeDirectory}/.zshrc.local".text = ''
      export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
    '';

    "${config.xdg.configHome}/feh/themes".text = ''
      feh --reverse --auto-rotate --fullscreen
    '';

    "${config.xdg.configHome}/feh/buttons".text = ''
      # make scroll wheel (mousewheel up and down) zoom, instead of flipping images
      zoom_in 4
      zoom_out 5
    '';

    "${config.xdg.configHome}/zathura/zathurarc".text = ''
      set selection-clipboard clipboard
    '';

    "${config.xdg.configHome}/stylua/stylua.toml".text = ''
      column_width = 120
      line_endings = "Unix"
      indent_type = "Spaces"
      indent_width = 2
      quote_style = "AutoPreferDouble"
      no_call_parentheses = false
    '';

    "${config.xdg.configHome}/vale/vale.ini".text = ''
      StylesPath = ${pkgs.vale}/share/vale/styles

      [*.md]
      BasedOnStyles = proselint, write-good, Joblint
      MinAlertLevel = suggestion
    '';

    # "bin".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixconfig/bin";
  };
}
