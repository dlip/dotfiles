{
  appimageTools,
  fetchurl,
  lib,
  stdenv,
}:

let
  pname = "rommix";
  version = "0.25.0";
  releases = {
    x86_64-linux = {
      arch = "x86_64";
      hash = "sha256-8+WwhlDMl1NkDrQ5EwFfjM+1QWHIEUn0VR8M8bSLK/w=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-yisMJ/TYvzqjTpxk8k1rT/TrgzVwYxRb8m9eYFSrl30=";
    };
  };
  release = releases.${stdenv.hostPlatform.system};
  src = fetchurl {
    url = "https://github.com/leclercb/rommix/releases/download/v${version}/RomMix-${release.arch}.AppImage";
    inherit (release) hash;
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm644 ${contents}/be.bl_it.RomMix.desktop "$out/share/applications/be.bl_it.RomMix.desktop"
    substituteInPlace "$out/share/applications/be.bl_it.RomMix.desktop" \
      --replace-fail 'Exec=AppRun' 'Exec=rommix'
    cp -r ${contents}/usr/share/icons "$out/share/icons"
  '';

  meta = {
    description = "Controller-friendly desktop client for RomM";
    homepage = "https://github.com/leclercb/rommix";
    license = lib.licenses.mit;
    mainProgram = "rommix";
    platforms = builtins.attrNames releases;
  };
}
