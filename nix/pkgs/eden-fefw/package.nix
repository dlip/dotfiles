{
  eden,
  fetchgit,
  src,
}:

let
  libgav1 = fetchgit {
    url = "https://chromium.googlesource.com/codecs/libgav1";
    rev = "c1deec657b32b911920c78e078cfd089faa77200";
    hash = "sha256-HV9Ob0UywJcJD9+crmPmZmx8rJMomJQU0KZbCxBg5Ww=";
    fetchSubmodules = false;
  };
in
eden.overrideAttrs (old: {
  pname = "eden-fefw";
  version = "unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  cmakeFlags = old.cmakeFlags ++ [ "-DFETCHCONTENT_SOURCE_DIR_LIBGAV1=${libgav1}" ];

  postPatch = (old.postPatch or "") + ''
    substituteInPlace src/yuzu/CMakeLists.txt \
      --replace-fail 'OUTPUT_NAME "eden"' 'OUTPUT_NAME "eden-fefw"'
    substituteInPlace src/CMakeLists.txt \
      --replace-fail 'OUTPUT_NAME "eden-cli"' 'OUTPUT_NAME "eden-fefw-cli"'
    substituteInPlace src/yuzu/main.cpp \
      --replace-fail 'dev.eden_emu.eden' 'dev.eden_emu.eden-fefw'
  '';

  postInstall = (old.postInstall or "") + ''
    for entry in \
      applications/dev.eden_emu.eden.desktop \
      icons/hicolor/scalable/apps/dev.eden_emu.eden.svg \
      metainfo/dev.eden_emu.eden.metainfo.xml \
      mime/packages/dev.eden_emu.eden.xml; do
      mv "$out/share/$entry" "$out/share/''${entry/dev.eden_emu.eden/dev.eden_emu.eden-fefw}"
    done

    substituteInPlace "$out/share/applications/dev.eden_emu.eden-fefw.desktop" \
      --replace-fail 'Name=Eden' 'Name=Eden FEFW' \
      --replace-fail 'Icon=dev.eden_emu.eden' 'Icon=dev.eden_emu.eden-fefw' \
      --replace-fail 'TryExec=eden' 'TryExec=eden-fefw' \
      --replace-fail 'Exec=eden %f' 'Exec=eden-fefw %f'
    substituteInPlace "$out/share/metainfo/dev.eden_emu.eden-fefw.metainfo.xml" \
      --replace-fail 'dev.eden_emu.eden' 'dev.eden_emu.eden-fefw' \
      --replace-fail '<name>eden</name>' '<name>Eden FEFW</name>' \
      --replace-fail '<binary>yuzu</binary>' '<binary>eden-fefw</binary>' \
      --replace-fail '<binary>yuzu-cmd</binary>' '<binary>eden-fefw-cli</binary>'
  '';

  meta = old.meta // {
    description = "Eden fork focused on Fire Emblem: Fortune's Weave";
    homepage = "https://git.eden-emu.dev/Duck912/eden-fefw";
    mainProgram = "eden-fefw";
    # Prefer Eden and PokeDinner's shared server and data files when installed together.
    priority = (old.meta.priority or 5) + 2;
  };
})
