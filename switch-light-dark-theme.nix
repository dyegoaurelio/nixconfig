{ config, pkgs, lib, ... }:

let
  # Script to switch to light theme
  switchToLightThemeScript = pkgs.writeScript "switch-to-light-theme.sh" ''
    #!/bin/sh
    # Command to switch to the light theme
    ${pkgs.gsettings-desktop-schemas}/bin/gsettings set org.gnome.desktop.interface color-scheme default
  '';

  # Script to switch to dark theme
  switchToDarkThemeScript = pkgs.writeScript "switch-to-dark-theme.sh" ''
    #!/bin/sh
    # Command to switch to the dark theme
    ${pkgs.gsettings-desktop-schemas}/bin/gsettings set org.gnome.desktop.interface color-scheme prefer-dark

  '';
in
{
  systemd.services.switch-to-light-theme = {
    description = "Switch to Light Theme";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = switchToLightThemeScript;
    };
  };

  systemd.services.switch-to-dark-theme = {
    description = "Switch to Dark Theme";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = switchToDarkThemeScript;
    };
  };

  systemd.timers.switch-to-light-theme = {
    description = "Timer for Light Theme Switch";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "08:00";
    };
  };

  systemd.timers.switch-to-dark-theme = {
    description = "Timer for Dark Theme Switch";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "18:00";
    };
  };

  environment.systemPackages = with pkgs; [
    gsettings-desktop-schemas
  ];
}
