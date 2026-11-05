{
  eden,
  fetchFromGitHub,
  src,
}:

eden.overrideAttrs (old: {
  pname = "lichii";
  version = "unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  cmakeFlags = old.cmakeFlags ++ [
    "-DOpus_CUSTOM_DIR=${
      fetchFromGitHub {
        owner = "xiph";
        repo = "opus";
        rev = "a3f0ec02b3";
        hash = "sha256-SyGUedfpqWb5+URiX0Tw/g3VPWxJBNPDSHmv/j9xHls=";
      }
    }"
    "-Dzstd_CUSTOM_DIR=${
      fetchFromGitHub {
        owner = "facebook";
        repo = "zstd";
        rev = "33618c8";
        hash = "sha256-UP99PUq8N+fmU972Jxim4f9u//T+4hRW+wuTZzWg3uI=";
      }
    }"
  ];

  postPatch = (old.postPatch or "") + ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail 'OUTPUT_NAME "eden-cli"' 'OUTPUT_NAME "lichii-cli"'
  '';

  postInstall = ''
    install -Dm644 "$src/dist/nx2_switches.txt" "$out/bin/nx2_switches.txt"
    install -Dm644 "$src/dist/72-eden-input.rules" "$out/lib/udev/rules.d/72-eden-input.rules"
  '';

  meta = old.meta // {
    description = "Experimental Nintendo Switch and Switch 2 emulator";
    homepage = "https://github.com/zortos293/Lichii";
    mainProgram = "lichii";
    priority = (old.meta.priority or 5) + 2;
  };
})
