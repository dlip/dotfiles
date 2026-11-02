{
  lib,
  stdenv,
  python3Packages,
  python3,
  src,
  pkgsCross,
  makeWrapper,
}:

let
  arm-embedded-cc = pkgsCross.arm-embedded.buildPackages.gcc;
in

stdenv.mkDerivation {
  pname = "fusee-launcher";
  version = "unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  makeFlags = [
    "CROSS_COMPILE=${arm-embedded-cc.targetPrefix}"
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share
    cp fusee-launcher.py $out/bin/fusee-launcher
    cp intermezzo.bin $out/share/intermezzo.bin

    # Wrap with path to intermezzo.bin relocator binary in /share
    wrapProgram $out/bin/fusee-launcher \
      --add-flags "--relocator $out/share/intermezzo.bin" \
      --prefix PYTHONPATH : "$PYTHONPATH:$(toPythonPath $out)"
  '';

  nativeBuildInputs = [
    arm-embedded-cc
    makeWrapper
    python3Packages.wrapPython
  ];
  buildInputs = [
    python3
    python3Packages.pyusb
  ];
  pythonPath = with python3Packages; [ pyusb ];

  meta = with lib; {
    homepage = "https://github.com/soup6020/fusee-launcher";
    description = "Work-in-progress launcher for one of the Tegra X1 bootROM exploits";
    mainProgram = "fusee-launcher";
    license = licenses.gpl2;
    maintainers = with maintainers; [ pneumaticat ];
  };

}
