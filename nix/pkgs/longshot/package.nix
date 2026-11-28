{
  lib,
  stdenv,
  rustPlatform,
  src,
  clang,
  lld,
  llvm,
  pkg-config,
  ffmpeg,
  SDL2,
  sdl3,
  vulkan-loader,
  vulkan-headers,
  spirv-headers,
  vulkan-memory-allocator,
  wayland,
  libxkbcommon,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  fontconfig,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:
let
  target = stdenv.hostPlatform.rust.rustcTarget;
in
rustPlatform.buildRustPackage {
  pname = "longshot";
  version = "0-unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  cargoHash = "sha256-8bciKQ5C9i3VN2xx45xn3mDT77w1sRLsrp9UTX4ib84=";
  cargoBuildFlags = [
    "-p"
    "longshot-builder"
    "-p"
    "longshot-packager"
  ];
  cargoTestFlags = [
    "-p"
    "longshot-builder"
  ];
  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];
  nativeCheckInputs = [ clang ];

  postPatch = ''
    substituteInPlace builder/crates/build-compile/src/packages.rs \
      --replace-fail '(Some(c), Some(l)) => Ok((c, l)),' \
        '(Some(c), Some(mut l)) => { l.push("-Wl,-rpath,${lib.getLib ffmpeg}/lib".into()); Ok((c, l)) },'
    substituteInPlace host/posix/win32_posix.c \
      --replace-fail 'snprintf(base, sizeof path - (size_t)(base - path), "%s", mapped);' 'snprintf(path, sizeof path, "%s", mapped);' \
      --replace-fail '"libSDL3.so.0"' '"${lib.getLib sdl3}/lib/libSDL3.so.0"' \
      --replace-fail '"libSDL2-2.0.so.0"' '"${lib.getLib SDL2}/lib/libSDL2-2.0.so.0"' \
      --replace-fail '"libvulkan.so.1"' '"${lib.getLib vulkan-loader}/lib/libvulkan.so.1"'
  '';

  postBuild = ''
    cargo build --frozen --target ${target} --profile game -p longshot-rs -j "$NIX_BUILD_CORES"
  '';

  installPhase = ''
    runHook preInstall
    tools=$out/share/longshot
    prebuilt=$tools/longshot-rs/prebuilt/linux-x64
    mkdir -p "$tools" "$out/bin"
    cp -r Cargo.toml Cargo.lock assets builder game gpu host longshot-rs third_party tools.lock "$tools/"
    mkdir -p "$prebuilt"
    target/${target}/release/longshot-packager rust-key --root "$tools" > "$prebuilt/sources.key"
    install -m644 target/${target}/game/liblongshot_rs.a "$prebuilt/"
    install -m755 target/${target}/release/longshot-builder "$out/bin/"
    wrapProgram "$out/bin/longshot-builder" \
      --prefix PATH : ${
        lib.makeBinPath [
          clang
          lld
          llvm
          pkg-config
        ]
      } \
      --prefix PKG_CONFIG_PATH : ${lib.makeSearchPath "lib/pkgconfig" [ (lib.getDev ffmpeg) ]} \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          wayland
          libxkbcommon
          libx11
          libxcursor
          libxi
          libxrandr
          fontconfig
          vulkan-loader
        ]
      } \
      --set-default LONGSHOT_ROOT "$tools" \
      --set LONGSHOT_NO_SELF_UPDATE 1 \
      --set LONGSHOT_VULKAN_HEADERS ${vulkan-headers} \
      --set LONGSHOT_SPIRV_HEADERS ${spirv-headers} \
      --set LONGSHOT_VMA_HEADERS ${vulkan-memory-allocator} \
      --set LONGSHOT_SDL2 ${lib.getLib SDL2}/lib/libSDL2-2.0.so.0

    cat > "$out/bin/longshot" <<'SCRIPT'
    #!${stdenv.shell}
    set -eu
    case "''${1:-}" in
      --cli)
        shift
        exec @builder@ "$@"
        ;;
      --play|--launch) shift ;;
    esac
    folder=''${1:-$HOME/Games/Longshot}
    cd -- "$folder"
    export LONGSHOT_NO_UPDATE_CHECK=1
    if [ -f longshot_build.json ]; then
      exec ./longshot
    fi
    exec ./bin/longshot
    SCRIPT
    substituteInPlace "$out/bin/longshot" --replace-fail @builder@ "$out/bin/longshot-builder"
    chmod +x "$out/bin/longshot"
    install -Dm644 assets/longshot.png "$out/share/icons/hicolor/256x256/apps/longshot.png"
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "longshot";
      desktopName = "Longshot";
      comment = "The Legend of Zelda: Ocarina of Time, built from your copy";
      exec = "longshot --play";
      icon = "longshot";
      categories = [ "Game" ];
      terminal = false;
      startupWMClass = "dev.magicbean.Longshot";
    })
  ];

  meta = {
    description = "Build and run Ocarina of Time natively from your own game dump";
    homepage = "https://git.magicbean.dev/MagicBeanDev/Longshot";
    license = lib.licenses.gpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "longshot";
  };
}
