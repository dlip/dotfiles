{ inputs, ... }:
{
  debug = false;
  imports = [ inputs.flake-parts.flakeModules.modules ];
}
