{
  ipafont,
  plex-desktop,
  writeText,
}:

let
  fontsConf = writeText "plex-desktop-fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <include>/etc/fonts/fonts.conf</include>
      <dir>${ipafont}/share/fonts</dir>
      <alias binding="strong">
        <family>sans-serif</family>
        <prefer>
          <family>DejaVu Sans</family>
          <family>IPAGothic</family>
        </prefer>
      </alias>
    </fontconfig>
  '';
in
plex-desktop.override {
  extraEnv.FONTCONFIG_FILE = toString fontsConf;
}
