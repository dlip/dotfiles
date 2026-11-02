{
  eden,
  src,
}:

eden.overrideAttrs (old: {
  pname = "pokedinner";
  version = "unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  postInstall = (old.postInstall or "") + ''
    mv "$out/bin/eden-cli" "$out/bin/eglantine-cli"

    for entry in \
      applications/dev.eden_emu.eden.desktop \
      icons/hicolor/scalable/apps/dev.eden_emu.eden.svg \
      metainfo/dev.eden_emu.eden.metainfo.xml \
      mime/packages/dev.eden_emu.eden.xml; do
      mv "$out/share/$entry" "$out/share/''${entry/dev.eden_emu.eden/dev.eglantine.eglantine}"
    done

    substituteInPlace "$out/share/applications/dev.eglantine.eglantine.desktop" \
      --replace-fail 'Name=Eglantine' 'Name=PokeDinner'
    substituteInPlace "$out/share/metainfo/dev.eglantine.eglantine.metainfo.xml" \
      --replace-fail 'dev.eden_emu.eden' 'dev.eglantine.eglantine' \
      --replace-fail '<name>eden</name>' '<name>PokeDinner</name>' \
      --replace-fail '<binary>yuzu</binary>' '<binary>eglantine</binary>'
  '';

  meta = old.meta // {
    description = "Nintendo Switch emulator based on Eglantine and Eden, focused on Pokopia";
    homepage = "https://git.eden-emu.dev/Franseven/PokeDinner-a-Eglantine-Fork";
    mainProgram = "eglantine";
    # Prefer Eden's shared server and data files when both packages are installed.
    priority = (old.meta.priority or 5) + 1;
  };
})
