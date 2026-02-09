{ inputs, ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # opentabletdriver
            "dotnet-runtime-6.0.36"
            "dotnet-sdk-wrapped-6.0.428"
            "dotnet-sdk-6.0.428"
            "libsoup-2.74.3"
            "ventoy-1.1.10"
          ];
        };
        overlays = (import ../pkgs inputs) ++ [
          (final: prev: {
            stable = import inputs.nixpkgs-stable {
              inherit system;
              config = {
                allowUnfree = true;
                permittedInsecurePackages = [
                  "freeimage-3.18.0-unstable-2024-04-18"
                ];
              };
              overlays = (import ../pkgs/stable.nix inputs);
            };
            cudaPkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                cudaSupport = true;
              };
            };
          })
        ];
      };
    };
}
