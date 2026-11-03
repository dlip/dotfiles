{
  lib,
  python3Packages,
  src,
}:

python3Packages.buildPythonApplication {
  pname = "nup";
  version = "0.1.0-unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  pyproject = true;

  inherit src;

  sourceRoot = "source/tools/nup";
  build-system = [ python3Packages.setuptools ];
  dependencies = [ python3Packages.zstandard ];
  pythonImportsCheck = [ "nup.cli" ];

  meta = {
    description = "Pack, inspect, extract and verify NUP game dump containers";
    homepage = "https://github.com/a55uka/nup";
    license = lib.licenses.unfree;
    mainProgram = "nup";
  };
}
