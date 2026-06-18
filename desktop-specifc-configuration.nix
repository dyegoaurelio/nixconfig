{ config, pkgs, ... }:

{
  networking.hostName = "nixos-desktop";
  fileSystems."/data/m2_extra" = {
    device = "/dev/disk/by-label/m2extra";
    fsType = "ext4";
  };

  #   fileSystems."/data/ssd_extra" =
  # { device = "/dev/disk/by-label/Files";
  #   fsType = "ext4";
  # };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "ntsync" ];

}
