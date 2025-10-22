{ }:
let
  pkgs = import (builtins.fetchTarball {
    # nixpkgs 25.05-release 04 July 2025
    url = "https://github.com/NixOS/nixpkgs/archive/2830eec81e9c3a1b2319922c18a7fa6e26e513fb.tar.gz";
  }) { };

in
pkgs.callPackage ./csv2ofx.nix { }
