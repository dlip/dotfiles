{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  releases = {
    x86_64-linux = {
      arch = "x64";
      hash = "sha256-Z5ZAVJMffnSEi/57VP8fDKzcJVlsKeOnmHb3bg8kB6g=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-YPncD+fD4zVchAxeIcK2W3cLdLp4Vnrsei5fhGuAh84=";
    };
  };
  release = releases.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rom-converto";
  version = "0.24.0";

  src = fetchurl {
    url = "https://github.com/DevYukine/rom-converto/releases/download/v${finalAttrs.version}/rom-converto-cli-linux-${release.arch}-musl";
    inherit (release) hash;
  };

  dontUnpack = true;
  dontStrip = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 "$src" "$out/bin/rom-converto"
    runHook postInstall
  '';

  meta = {
    description = "Convert, compress, and inspect ROM images";
    homepage = "https://github.com/DevYukine/rom-converto";
    license = lib.licenses.mit;
    mainProgram = "rom-converto";
    platforms = builtins.attrNames releases;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
