{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  languages.odin.enable = true;

  packages = [ pkgs.raylib ];
}
