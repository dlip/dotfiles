{...}: {
  xdg.desktopEntries = {
    chrome-wayland = {
      name = "Google Chrome Wayland";
      genericName = "Google Chrome Wayland";
      exec = "google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland";
    };
  };
}