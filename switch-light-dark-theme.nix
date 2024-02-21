{ config, pkgs, lib, ... }:

let
  switchThemeScript = pkgs.writeScript "switch-theme.sh" ''
    #!/bin/sh
    currentHour=$(date +"%H")
    
    if [ $currentHour -ge 8 ] && [ $currentHour -lt 18 ]; then
      # Between 08:00 and 18:00, switch to the light theme
      ${pkgs.gsettings-desktop-schemas}/bin/gsettings set org.gnome.desktop.interface color-scheme default
    else
      # Otherwise, switch to the dark theme
      ${pkgs.gsettings-desktop-schemas}/bin/gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    fi
  '';

in
{
  systemd.services.switch-theme = {
    description = "Switch Theme on Boot";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = switchThemeScript;
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.timers.switch-theme = {
    description = "Timer for Theme Switch";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";  # Run the script 1 minute after boot
    };
  };


  systemd.services.switch-to-light-theme = {
    description = "Switch to Light Theme";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = switchThemeScript;
    };
  };

  systemd.services.switch-to-dark-theme = {
    description = "Switch to Dark Theme";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = switchThemeScript;
    };
  };

  systemd.timers.switch-to-light-theme = {
    description = "Timer for Light Theme Switch";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "08:01";
    };
  };

  systemd.timers.switch-to-dark-theme = {
    description = "Timer for Dark Theme Switch";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "18:01";
    };
  };

  environment.systemPackages = with pkgs; [
    gsettings-desktop-schemas
  ];
}
