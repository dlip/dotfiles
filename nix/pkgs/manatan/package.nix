{
  stdenv,
  fetchurl,
  dpkg,
  buildFHSEnv,
}:

let

  pkg = stdenv.mkDerivation (finalAttrs: {
    pname = "manatan";
    version = "6.1.41";

    src =
      let
        selectSystem =
          attrs:
          attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
        system = selectSystem {
          x86_64-linux = "amd64";
          aarch64-linux = "arm64";
        };
      in
      fetchurl {
        url = "https://github.com/KolbyML/Manatan/releases/download/v${finalAttrs.version}/manatan_${finalAttrs.version}_${system}.deb";
        sha256 = selectSystem {
          x86_64-linux = "sha256-qj7d4xm8lBZXQzQHKO9n2e2cngt+TwNEw0/b6WUd1mM=";
          aarch64-linux = "sha256-dUi8kvhv6vFeutlQ929d9+L4he2mJyG5Yg2r6fLUSXc=";
        };
      };

    nativeBuildInputs = [ dpkg ];
    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';
    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r usr/lib usr/share "$out/"
      substituteInPlace "$out/share/applications/manatan.desktop" \
        --replace-fail "Exec=/usr/bin/manatan" "Exec=manatan"
      runHook postInstall
    '';

    meta = {
      homepage = "https://manatan.com";
      description = "Seamless immersion language learning for anime, manga, novels on all platforms";
    };
  });

in

buildFHSEnv {
  inherit (pkg) pname version;
  meta = pkg.meta // {
    mainProgram = "manatan";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };

  runScript = "${pkg}/lib/manatan/manatan-bootstrapper";
  extraInstallCommands = ''
    mkdir -p "$out/share"
    cp -r ${pkg}/share/applications ${pkg}/share/icons "$out/share/"
  '';

  targetPkgs =
    pkgs: with pkgs; [
      fontconfig
      wayland
      libxkbcommon
      freetype
      libz
      libGL
      glib
      gtk3
      libsecret
      gdk-pixbuf
      harfbuzz
      libepoxy
      curl
      expat
      nspr
      nss
      dbus
      at-spi2-core
      cups
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxi
      libxrandr
      libgbm
      libxcb
      cairo
      pango
      lsof
      udev
      alsa-lib
      libgcc
      mpv
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      pipewire
    ];
}
