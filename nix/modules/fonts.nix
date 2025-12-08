{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    font-awesome
    fontconfig
    hachimarupop
    hanazono
    noto-fonts
    noto-fonts-cjk-sans
    # noto-fonts-emoji # broken
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.roboto-mono
    nerd-fonts.sauce-code-pro
  ];
}
