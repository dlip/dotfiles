{
  stdenv,
  src,
  rustPlatform,
  fetchurl,
  fetchYarnDeps,
  applyPatches,
  yarnConfigHook,
  yarn,
  nodejs_22,
  pkg-config,
  cmake,
  yasm,
  perl,
  python3,
  openssl,
  fontconfig,
  freetype,
  bzip2,
  libxkbcommon,
  wayland,
  makeDesktopItem,
  runCommand,
  writeText,
  unzip,
  buildFHSEnv,
}:

let
  version = "0.1.0-unstable-${builtins.substring 0 8 (src.lastModifiedDate or "19700101")}";

  webuiSource = applyPatches {
    name = "manatan-webui-source";
    src = "${src}/WebUI";
    patches = [
      ./webui-yarn-lock.patch
      ./prefer-hls-js.patch
      ./separate-hls-audio.patch
    ];
  };

  webui = stdenv.mkDerivation {
    pname = "manatan-webui";
    inherit version;
    src = webuiSource;
    yarnOfflineCache = fetchYarnDeps {
      yarnLock = "${webuiSource}/yarn.lock";
      hash = "sha256-CL+EwQaCxEibv3O3k5m75h8KGAU/jpTSmH4rTmPtPK0=";
    };
    nativeBuildInputs = [
      yarnConfigHook
      yarn
      nodejs_22
    ];
    buildPhase = ''
      runHook preBuild
      cp .env.template .env
      yarn --offline exec vite build
      runHook postBuild
    '';
    installPhase = ''
      runHook preInstall
      cp -r build "$out"
      runHook postInstall
    '';
  };

  extensionServer = fetchurl {
    url = "https://github.com/KolbyML/Manatan/releases/download/v6.2.19/manatan-runtime-extension-server-e0b8c0cb02db80e089091697a22b5795db61d9dc850405339da02732d1f5b09d.zip";
    hash = "sha256-CecmAw6v4Ztw0PqniBLq4abSJ14H29v+OCvch93s8rY=";
  };

  serverLibrary =
    runCommand "manatan-server-library"
      {
        src = fetchurl {
          url = "https://github.com/KolbyML/Manatan-Server-Public/releases/download/stable/manatan-server-${stdenv.hostPlatform.rust.rustcTarget}.a";
          hash =
            {
              x86_64-linux = "sha256-AcD/6C2CMnzephlR0nKwdZepen3e1S0c1Oia2Kb61/g=";
              aarch64-linux = "sha256-rwPCADxgLsD1Yz3FFuRweG6LAM2a/RChq2FGdze8Spg=";
            }
            .${stdenv.hostPlatform.system};
        };
      }
      ''
        mkdir -p "$out/lib"
        cp "$src" "$out/lib/libmanatan_server.a"
        ln -s libmanatan_server.a "$out/lib/libsqlite3.a"
      '';

  serverBuildScript = writeText "manatan-server-build.rs" ''
    fn main() {
        println!("cargo:rustc-link-search=native=${serverLibrary}/lib");
        println!("cargo:rustc-link-lib=static:-bundle=manatan_server");
        println!("cargo:rustc-link-lib=dylib=bz2");
        println!("cargo:rustc-link-lib=dylib=fontconfig");
        println!("cargo:rustc-link-lib=dylib=freetype");
    }
  '';

  desktopItem = makeDesktopItem {
    name = "manatan";
    desktopName = "Manatan";
    exec = "manatan";
    icon = "manatan";
    categories = [ "Education" ];
  };

  pkg = rustPlatform.buildRustPackage {
    pname = "manatan";
    inherit version src;
    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      allowBuiltinFetchGit = true;
    };
    cargoBuildFlags = [
      "--package"
      "manatan"
    ];
    cargoTestFlags = [
      "--package"
      "manatan"
    ];
    nativeBuildInputs = [
      pkg-config
      cmake
      yasm
      perl
      python3
      unzip
      rustPlatform.bindgenHook
    ];
    buildInputs = [
      openssl
      fontconfig
      freetype
      bzip2
      libxkbcommon
      wayland
    ];
    env.OPENSSL_NO_VENDOR = "1";

    postPatch = ''
      # Upstream's backend build script downloads a mutable release during compilation.
      serverDir=$(find "$cargoDepsCopy" -maxdepth 1 -type d -name 'manatan-server-public-*' -print -quit)
      test -n "$serverDir"
      cp ${serverBuildScript} "$serverDir/build.rs"
      python3 - "$serverDir" <<'PYTHON'
      import hashlib, json, pathlib, sys
      directory = pathlib.Path(sys.argv[1])
      checksum = directory / ".cargo-checksum.json"
      data = json.loads(checksum.read_text())
      data["files"]["build.rs"] = hashlib.sha256((directory / "build.rs").read_bytes()).hexdigest()
      checksum.write_text(json.dumps(data))
      PYTHON
      cp -r ${webui} bin/manatan/resources/webui
      unzip -q ${extensionServer} -d extension-server
      cp extension-server/Extension-Server.jar bin/manatan/resources/Suwayomi-Server.jar
    '';

    postInstall = ''
      mkdir -p "$out/share/icons/hicolor/256x256/apps"
      cp bin/manatan/resources/faviconlogo.png "$out/share/icons/hicolor/256x256/apps/manatan.png"
      cp -r ${desktopItem}/share/applications "$out/share/"
    '';

    passthru = { inherit webui; };
    meta = {
      homepage = "https://manatan.com";
      description = "Seamless immersion language learning for anime, manga, novels on all platforms";
    };
  };

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

  runScript = "${pkg}/bin/manatan";
  # AniZone's video-page regex can overflow the JVM's default thread stack.
  profile = ''
    export JAVA_TOOL_OPTIONS="''${JAVA_TOOL_OPTIONS:-} -Xss16m"
  '';
  extraInstallCommands = ''
    mkdir -p "$out/share"
    cp -r ${pkg}/share/applications ${pkg}/share/icons "$out/share/"
  '';

  passthru = { inherit pkg webui; };

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
      jdk21_headless
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      pipewire
    ];
}
