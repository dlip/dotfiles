{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "switch-library-manager";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "giwty";
    repo = "switch-library-manager";
    rev = "f69daa7e5e3bc9fc2cc17ad839a12ac3bf5e0372";
    hash = "sha256-tbCTtFNpY4M47Ws/ohoyBOG4aQwrHJ/CozYxgO6cd5k=";
  };

  vendorHash = "sha256-scAnQ14ZGx2wheqrJzmKiUc/31siUSLYuWtO3GCZeLI=";
  subPackages = [ "." ];

  postPatch = ''
    rm gui.go prod.keys
    sed -i '/appSettings.GUI = true/,/^}/c\
    CreateConsole(workingFolder, sugar).Start()\n}' main.go
    substituteInPlace main.go --replace-fail \
      'workingFolder := filepath.Dir(exePath)' \
      'configDir, err := os.UserConfigDir()
        if err != nil { panic(err) }
        workingFolder := filepath.Join(configDir, "switch-library-manager")
        if err := os.MkdirAll(workingFolder, 0700); err != nil { panic(err) }'
  '';

  meta = {
    description = "Command-line manager for Nintendo Switch game backup libraries";
    homepage = "https://github.com/giwty/switch-library-manager";
    license = lib.licenses.unfree;
    mainProgram = "switch-library-manager";
    platforms = lib.platforms.unix;
  };
}
