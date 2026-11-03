{
  lib,
  buildGoModule,
  src,
}:

buildGoModule {
  pname = "switch-library-manager";
  version = "unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  modRoot = "src";
  vendorHash = "sha256-xpc+E3nABrAy+v5rXolUAxIvvr5wZOSmvyHI1Sl2VAo=";
  subPackages = [ "." ];

  postPatch = ''
    rm src/gui*.go src/embedded_assets_test.go
    sed -i '/files, err := AssetDir(workingFolder)/,/^\t}/d' src/main.go
    substituteInPlace src/main.go \
      --replace-fail 'useGUI := appSettings.GUI' 'useGUI := false' \
      --replace-fail 'CreateGUI(workingFolder, sugar).Start()' \
        'fmt.Fprintln(os.Stderr, "This package provides console mode only"); os.Exit(1)'
    substituteInPlace src/main.go --replace-fail \
      'workingFolder := filepath.Dir(exePath)' \
      'configDir, err := os.UserConfigDir()
        if err != nil { panic(err) }
        workingFolder := filepath.Join(configDir, "switch-library-manager")
        if err := os.MkdirAll(workingFolder, 0700); err != nil { panic(err) }'
  '';

  checkPhase = ''
    runHook preCheck
    go test ./...
    runHook postCheck
  '';

  meta = {
    description = "Command-line manager for Nintendo Switch game backup libraries";
    homepage = "https://github.com/trembon/switch-library-manager";
    license = lib.licenses.mit;
    mainProgram = "switch-library-manager";
    platforms = lib.platforms.unix;
  };
}
