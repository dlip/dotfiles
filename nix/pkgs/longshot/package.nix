{
  lib,
  stdenv,
  src,
  astcEncoderSrc,
  textureDecoderSrc,
  python3,
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
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:
let
  python = python3.withPackages (
    ps:
    let
      astcEncoder = ps.buildPythonPackage {
        pname = "astc-encoder-py";
        version = "0.1.12";
        src = astcEncoderSrc;
        pyproject = true;
        build-system = [
          ps.setuptools
          ps.wheel
          ps.archspec
        ];
        dependencies = [ ps.archspec ];
        # Build every x86 variant, without -march=native.
        env.CIBUILDWHEEL = "1";
        postPatch = ''
          substituteInPlace pyproject.toml --replace-fail 'setuptools<72.2.0' 'setuptools'
        '';
        pythonImportsCheck = [ "astc_encoder" ];
      };
      textureDecoder = ps.buildPythonPackage {
        pname = "texture2ddecoder";
        version = "1.0.6";
        src = textureDecoderSrc;
        pyproject = true;
        build-system = [
          ps.setuptools
          ps.wheel
        ];
        postPatch = ''
          substituteInPlace pyproject.toml --replace-fail 'setuptools<72.2.0' 'setuptools'
        '';
        pythonImportsCheck = [ "texture2ddecoder" ];
      };
    in
    with ps;
    [
      capstone
      lz4
      numpy
      unicorn
      zstandard
      fonttools
      pillow
      astcEncoder
      textureDecoder
    ]
  );
  runtimePath = lib.makeBinPath [
    clang
    lld
    llvm
    pkg-config
  ];
  pkgConfigPath = lib.makeSearchPath "lib/pkgconfig" [ (lib.getDev ffmpeg) ];
in
stdenv.mkDerivation {
  pname = "longshot";
  version = "0-unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    clang
  ];
  dontConfigure = true;

  postPatch = ''
    substituteInPlace nx2/build.py \
      --replace-fail 'return cflags, libs' 'return cflags, libs + ["-Wl,-rpath,${lib.getLib ffmpeg}/lib"]'
    substituteInPlace host/posix/win32_posix.c \
      --replace-fail 'snprintf(base, sizeof path - (size_t)(base - path), "%s", mapped);' 'snprintf(path, sizeof path, "%s", mapped);' \
      --replace-fail '"libSDL3.so.0"' '"${lib.getLib sdl3}/lib/libSDL3.so.0"' \
      --replace-fail '"libSDL2-2.0.so.0"' '"${lib.getLib SDL2}/lib/libSDL2-2.0.so.0"' \
      --replace-fail '"libvulkan.so.1"' '"${lib.getLib vulkan-loader}/lib/libvulkan.so.1"'
  '';

  buildPhase = ''
    runHook preBuild
    export PYTHONDONTWRITEBYTECODE=1
    ${python}/bin/python3 -I third_party/a64-kit/lift/build_emit.py
    ${python}/bin/python3 -I -c "import sys; sys.path.insert(0, 'nx2'); import zbic; zbic.lib()"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    tools=$out/share/longshot
    mkdir -p "$tools" $out/bin
    cp -r nx2 host gpu third_party builder scripts assets LICENSE README.md requirements.txt tools.lock "$tools/"
    echo ${lib.escapeShellArg src.shortRev} > "$tools/VERSION"

    cat > $out/bin/longshot <<SCRIPT
    #!${stdenv.shell}
    case "\''${1:-}" in
      --cli)
        shift
        exec ${python}/bin/python3 -I "$tools/nx2/make_game.py" "\$@"
        ;;
      --help|-h)
        exec ${python}/bin/python3 -I "$tools/nx2/make_game.py" --help
        ;;
      --play|--launch)
        shift
        ;;
    esac
    exec "$tools/builder/linux/longshot-launch" "\$@"
    SCRIPT
    chmod +x $out/bin/longshot "$tools/builder/linux/longshot-launch"
    patchShebangs "$tools/builder/linux/longshot-launch" "$tools/builder/linux/longshot-folder"
    wrapProgram $out/bin/longshot \
      --prefix PATH : ${runtimePath} \
      --prefix PKG_CONFIG_PATH : ${pkgConfigPath} \
      --set LONGSHOT_TOOLS "$tools" \
      --set LONGSHOT_BUILDER_EXE "$out/bin/longshot" \
      --set LONGSHOT_VULKAN_HEADERS ${vulkan-headers} \
      --set LONGSHOT_SPIRV_HEADERS ${spirv-headers} \
      --set LONGSHOT_VMA_HEADERS ${vulkan-memory-allocator} \
      --set LONGSHOT_SDL2 ${lib.getLib SDL2}/lib/libSDL2-2.0.so.0 \
      --set PYTHONDONTWRITEBYTECODE 1
    install -Dm644 assets/longshot.png $out/share/icons/hicolor/256x256/apps/longshot.png
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
