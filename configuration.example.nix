{ config, pkgs, ... }:

{
  imports =
    [
      ./general-configuration.nix
      ./hardware-configuration.nix
      ./manual-hardware-configuration.nix
      ./laptop-specifc-configuration.nix
      ./nix-alien.nix
      ./switch-light-dark-theme.nix
      #./nix-encryption.nix
    ];

}
