{ config, pkgs, ... }:

{

  imports =
    [
      ./suspend-and-hibernate.nix
    ];

# power saving
services.power-profiles-daemon.enable = false;

services.tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 30;
      };
};


  services.logind.extraConfig = ''
     HandleLidSwitch=lock
     HandleLidSwitchExternalPower=lock

'';


# fingerprint reader
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };


}
