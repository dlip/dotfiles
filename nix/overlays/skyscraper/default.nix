{
  lib,
  stdenv,
  fetchFromGitHub,
  qt5,
  p7zip,
  python3,
  installShellFiles,

  # Whether to compile with XDG support
  # (See: https://gemba.github.io/skyscraper/XDG/)
  enableXdg ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "skyscraper";
  version = "3.18.0";

  src = fetchFromGitHub {
    owner = "Gemba";
    repo = "skyscraper";
    rev = "97d87bdaa137c26b43ae001a4b2abd54ec092749";
    hash = "sha256-Gg84XRVWvTOVbCeT1ZacS5jY5K4vT0M7KaJftVtCPr4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    qt5.wrapQtAppsHook
    qt5.qmake
    installShellFiles
  ];

  buildInputs = [ python3 ];

  postPatch = lib.optionalString enableXdg ''
    substituteInPlace skyscraper.pro --replace-fail "#DEFINES+=XDG" "DEFINES+=XDG"
  '';

  postInstall = ''
    installShellCompletion --cmd Skyscraper \
      --bash supplementary/bash-completion/Skyscraper.bash
  '';

  preFixup = ''
    qtWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ p7zip ]})
    chmod +x $out/bin/*.py
  '';

  env.PREFIX = placeholder "out";

  meta = {
    description = "Powerful and versatile game data scraper written in Qt and C++";
    homepage = "https://gemba.github.io/skyscraper/";
    downloadPage = "https://github.com/Gemba/skyscraper/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ashgoldofficial ];
    mainProgram = "Skyscraper";
    platforms = lib.platforms.linux;
  };
})
