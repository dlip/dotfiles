{
  lib,
  stdenv,
  src,
  python3,
  clang,
  lld,
  llvm,
  pkg-config,
  ffmpeg,
  SDL2,
  vulkan-loader,
  vulkan-headers,
  spirv-headers,
  vulkan-memory-allocator,
  makeWrapper,
}:
let
  python = python3.withPackages (
    ps: with ps; [
      capstone
      lz4
      numpy
      tkinter
      unicorn
      zstandard
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
  pname = "hookshot";
  version = "0-unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  nativeBuildInputs = [
    makeWrapper
    clang
  ];
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    export PYTHONDONTWRITEBYTECODE=1
    ${python}/bin/python3 -I third_party/a64-kit/lift/build_emit.py
    ${python}/bin/python3 -I -c "import sys; sys.path.insert(0, 'nx2'); import zbic; zbic.lib()"
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    tools=$out/share/hookshot
    mkdir -p "$tools" $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps
    cp -r nx2 host gpu third_party builder assets LICENSE readme.md "$tools/"
    echo ${lib.escapeShellArg src.shortRev} > "$tools/VERSION"
    mkdir -p "$tools/cpm"/{vulkanheaders,spirv-headers,vulkanmemoryallocator}
    ln -s ${vulkan-headers} "$tools/cpm/vulkanheaders/nix"
    ln -s ${spirv-headers} "$tools/cpm/spirv-headers/nix"
    ln -s ${vulkan-memory-allocator} "$tools/cpm/vulkanmemoryallocator/nix"

    cat > $out/bin/hookshot <<SCRIPT
    #!${stdenv.shell}
    case "\''${1:-}" in
      --cli)
        shift
        exec ${python}/bin/python3 -I "$tools/nx2/make_game.py" "\$@"
        ;;
      --play)
        shift
        exec "$tools/builder/linux/hookshot-launch" "\$@"
        ;;
    esac
    if [ -n "\''${1:-}" ] && [ -d "\$1" ]; then
      exec "$tools/builder/linux/hookshot-launch" "\$@"
    fi
    exec ${python}/bin/python3 -I "$tools/builder/linux/hookshot_builder.py" "\$@"
    SCRIPT
    chmod +x $out/bin/hookshot "$tools/builder/linux/hookshot-launch"
    patchShebangs "$tools/builder/linux/hookshot-launch"
    wrapProgram $out/bin/hookshot \
      --prefix PATH : ${runtimePath} \
      --prefix PKG_CONFIG_PATH : ${pkgConfigPath} \
      --set HOOKSHOT_TOOLS "$tools" \
      --set RX_CPM "$tools/cpm" \
      --set HOOKSHOT_SDL2 ${lib.getLib SDL2}/lib/libSDL2-2.0.so.0 \
      --set PYTHONDONTWRITEBYTECODE 1

    cp builder/linux/hookshot-builder.desktop $out/share/applications/hookshot-builder.desktop
    substituteInPlace $out/share/applications/hookshot-builder.desktop \
      --replace-fail "Exec=AppRun" "Exec=$out/bin/hookshot"
    cp assets/hookshot.png $out/share/icons/hicolor/256x256/apps/hookshot.png
    runHook postInstall
  '';

  postPatch = ''
    substituteInPlace nx2/build.py \
      --replace-fail 'return cflags, libs' 'return cflags, libs + ["-Wl,-rpath,${lib.getLib ffmpeg}/lib"]'
    substituteInPlace host/posix/win32_posix.c \
      --replace-fail 'snprintf(base, sizeof path - (size_t)(base - path), "%s", mapped);' 'snprintf(path, sizeof path, "%s", mapped);' \
      --replace-fail '"libSDL2-2.0.so.0"' '"${lib.getLib SDL2}/lib/libSDL2-2.0.so.0"' \
      --replace-fail '"libvulkan.so.1"' '"${lib.getLib vulkan-loader}/lib/libvulkan.so.1"'
  '';

  meta = {
    description = "Build and run Ocarina of Time natively from your own game dump";
    homepage = "https://github.com/NotRexed/Hookshot";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "hookshot";
  };
}
