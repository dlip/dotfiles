{
  lib,
  stdenvNoCC,
  src,
  python3,
  androidenv,
  android-tools,
  dotnet-sdk_10,
  qt6,
  shaderc,
  coreutils,
  util-linux,
}:
let
  python = python3.withPackages (
    ps: with ps; [
      lz4
      capstone
      pillow
      fonttools
      pyyaml
      pycryptodome
      pyside6
    ]
  );
  android = (androidenv.override { licenseAccepted = true; }).composeAndroidPackages {
    includeNDK = true;
    ndkVersions = [ "27.2.12479018" ];
    platformVersions = [ ];
    buildToolsVersions = [ ];
    includeEmulator = false;
    includeSystemImages = false;
  };
  ndk = "${android.ndk-bundle}/libexec/android-sdk/ndk-bundle";
in
stdenvNoCC.mkDerivation {
  pname = "nx2android";
  version = "0-unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  nativeBuildInputs = [ qt6.wrapQtAppsHook ];
  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];
  dontWrapQtApps = true;
  dontBuild = true;

  postPatch = ''
    substituteInPlace nxnative/dm/android/build.py \
      --replace-fail "GLSLC = Path(a.ndk) / 'shader-tools' / host / ('glslc.exe' if os.name == 'nt' else 'glslc')" \
        "GLSLC = Path('${lib.getBin shaderc}/bin/glslc')"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/nx2android $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps
    cp -r porter gui nxnative packaging README.md $out/share/nx2android/
    cat > $out/bin/nx2android <<'SCRIPT'
    #!${stdenvNoCC.shell}
    set -eu
    cache="''${XDG_CACHE_HOME:-$HOME/.cache}/nx2android/$(basename @out@)"
    mkdir -p "$cache"
    (
      flock 9
      if [ ! -d "$cache/source" ]; then
        tmp=$(mktemp -d "$cache/source.XXXXXX")
        cp -R @out@/share/nx2android/. "$tmp/"
        chmod -R u+w "$tmp"
        mv "$tmp" "$cache/source"
      fi
    ) 9>"$cache/source.lock"
    export PYTHONPATH="$cache/source''${PYTHONPATH:+:$PYTHONPATH}"
    cd "$cache/source"
    exec ${python}/bin/python3 packaging/nx2android.py "$@"
    SCRIPT
    substituteInPlace $out/bin/nx2android --replace-fail '@out@' "$out"
    chmod +x $out/bin/nx2android
    wrapQtApp $out/bin/nx2android \
      --prefix PATH : ${
        lib.makeBinPath [
          dotnet-sdk_10
          android-tools
          coreutils
          util-linux
        ]
      } \
      --set-default ANDROID_NDK_HOME ${ndk} \
      --set DOTNET_ROOT ${dotnet-sdk_10}/share/dotnet \
      --set DOTNET_CLI_TELEMETRY_OPTOUT 1
    cp gui/icon.png $out/share/icons/hicolor/256x256/apps/nx2android.png
    cat > $out/share/applications/nx2android.desktop <<DESKTOP
    [Desktop Entry]
    Type=Application
    Name=nx2android
    Comment=Port your Switch games to Android
    Exec=$out/bin/nx2android
    Icon=nx2android
    Categories=Game;Development;
    Terminal=false
    DESKTOP
    runHook postInstall
  '';

  meta = {
    description = "Port Nintendo Switch games to Android from your own dumps";
    homepage = "https://github.com/shirai91/nx2android";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "nx2android";
  };
}
