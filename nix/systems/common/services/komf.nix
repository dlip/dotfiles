{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.komf;

  version = "1.7.0"; # adjust as needed
  jarName = "komf-${version}.jar";

  komfJar = pkgs.fetchurl {
    url = "https://github.com/Snd-R/komf/releases/download/${version}/${jarName}";
    sha256 = "sha256-o5cx4L+LgvI9ydfM7Nk2sWjRussQg7GLFIV/DcEVZ+k="; # fill in real sha256
  };

  komfPackage = pkgs.stdenv.mkDerivation {
    name = "komf-${version}";
    src = komfJar;

    buildCommand = ''
      mkdir -p $out/lib
      cp $src $out/lib/${jarName}
    '';
  };

  # Convert settings attrset → YAML in store
  applicationYml = pkgs.runCommand "komf-application-yml" { } ''
        mkdir -p $out
        cat > settings.json <<EOF
    ${builtins.toJSON cfg.settings}
    EOF
        ${pkgs.yj}/bin/yj -jy < settings.json > $out/application.yml
  '';

in
{
  options.services.komf = {
    enable = lib.mkEnableOption "Komf metadata fetcher service";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Komf configuration as a Nix attribute set.
        Will be serialized to application.yml automatically.
      '';
      example = {
        server.port = 8085;
      };
    };

    extraJavaOpts = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Additional JVM options.";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.openjdk
      komfPackage
    ];

    systemd.services.komf = {
      description = "Komf metadata fetcher";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.openjdk}/bin/java \
            ${cfg.extraJavaOpts} \
            -jar ${komfPackage}/lib/${jarName} \
            ${applicationYml}/application.yml
        '';
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
