{
  appimageTools,
  fetchurl,
  lib,
}:

appimageTools.wrapAppImage (finalAttrs: {
  pname = "plexamp";
  version = "4.50.20";

  src = fetchurl {
    url = "https://plexamp.plex.tv/desktop/Plexamp-${finalAttrs.version}-x86_64.AppImage";
    hash = "sha256-1+sb35I7LztW034DoCfVr5qLqBiBxwpOgZynereGXRw=";
  };

  contents = appimageTools.extract {
    inherit (finalAttrs) pname version src;
    postExtract = ''
      substituteInPlace "$out/apprun-hooks/linuxdeploy-plugin-gtk.sh" \
        --replace-fail 'export GDK_BACKEND=x11' 'export GDK_BACKEND="''${GDK_BACKEND:-wayland,x11}"'
    '';
  };

  extraPkgs = pkgs: [ pkgs.libgpg-error ];

  extraInstallCommands = ''
    install -Dm644 ${finalAttrs.contents}/Plexamp.desktop "$out/share/applications/plexamp.desktop"
    substituteInPlace "$out/share/applications/plexamp.desktop" \
      --replace-fail 'Exec=Plexamp' 'Exec=plexamp'
    cp -r ${finalAttrs.contents}/usr/share/icons "$out/share/icons"
  '';

  meta = {
    description = "Desktop music player for Plex";
    homepage = "https://plexamp.com/";
    license = lib.licenses.unfree;
    mainProgram = "plexamp";
    platforms = [ "x86_64-linux" ];
  };
})
