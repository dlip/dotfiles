{
  pkgs,
  ...
}:
{
  imports = [
    ./default.nix
    ./desktop.nix
  ];

  environment.systemPackages = with pkgs; [
    acpi
    appimage-run
    binutils
    btop
    # mimic
    btop
    evtest
    hdparm
    # fusee-launcher
    iotop
    iputils
    kanata
    # kdePackages.k3b # export QTWEBENGINE_DISABLE_SANDBOX=1; sudo -EH k3b
    kmonad
    krename
    mecab
    mkvtoolnix-cli
    # nix-du
    ns-usbloader
    pinentry-curses
    # python311Packages.adafruit-nrfutil
    qmk
    strace
    tagainijisho
    tiramisu
    traceroute
    usbutils
    usbimager
    ventoy
    xdotool
    xorg.xhost # add root to xsession: xhost si:localuser:root
  ];
}
