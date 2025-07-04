{
  pkgs ? import <nixpkgs> { },
}:

let
  python-with-meza = pkgs.python3.override {
    packageOverrides = self: super: {
      meza = self.callPackage ./meza.nix { };
    };
  };

in
pkgs.callPackage ./csv2ofx.nix {
  python3Packages = python-with-meza.pkgs;
}
