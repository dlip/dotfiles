{
  lib,
  buildGo127Module,
  python3,
  src,
}:

buildGo127Module {
  pname = "switch-library-manager";
  version = "unstable-${builtins.substring 0 8 src.lastModifiedDate}";
  inherit src;

  modRoot = "src";
  vendorHash = "sha256-1KaL7eK2VU0fTnvqiIOQu5pzCIhEKh3nvmWCYV02K2Q=";
  subPackages = [ "." ];

  postPatch = ''
    rm -r src/backend/app
    ${python3}/bin/python <<'PYTHON'
    from pathlib import Path

    path = Path("src/main.go")
    source = path.read_text()
    for line in (
        '\t"embed"\n',
        '\t"github.com/trembon/switch-library-manager/backend/app"\n',
        '//go:embed all:frontend\nvar frontendAssets embed.FS\n',
    ):
        assert line in source, line
        source = source.replace(line, "", 1)
    start = source.index("\tif useGUI {\n")
    end = source.index("\n}\n\nfunc resolveGUIMode", start)
    source = source[:start] + """\tconsole.FixConsoleOutput()
    \tconsoleapp.CreateConsole(dataFolder, sugar, consoleFlags).Start()""" + source[end:]
    old = "useGUI := resolveGUIMode(appSettings.GUI.Enabled, consoleFlags.Mode.IsSet(), consoleFlags.Mode.String())"
    assert old in source
    source = source.replace(old, "useGUI := false", 1)
    old = "resolveRuntimeDataFolder(runtime.GOOS, exePath, os.UserConfigDir)"
    assert old in source
    source = source.replace(old, "resolveNixDataFolder()", 1)
    source += """
    func resolveNixDataFolder() (string, error) {
        configDir, err := os.UserConfigDir()
        if err != nil { return "", err }
        dataDir := filepath.Join(configDir, "switch-library-manager")
        return dataDir, os.MkdirAll(dataDir, 0700)
    }
    """
    path.write_text(source)
    PYTHON
    gofmt -w src/main.go
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
