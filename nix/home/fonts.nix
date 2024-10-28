{pkgs, ...}: {
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    emacs-all-the-icons-fonts
    font-awesome
    fontconfig
    hachimarupop
    hanazono
    noto-fonts
    noto-fonts-cjk-sans
    # noto-fonts-emoji # broken
    (nerdfonts.override {fonts = ["FiraCode" "DroidSansMono" "RobotoMono" "SourceCodePro"];})
  ];
}
