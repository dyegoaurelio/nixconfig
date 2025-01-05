{ config, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "America/Fortaleza";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "br";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;



  services.flatpak.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dyego = {
    isNormalUser = true;
    description = "dyego";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      #postman
      google-chrome
      gnucash
      stow
      bat
      gnomeExtensions.media-controls
      bruno
      resources
      gnomeExtensions.dash-to-dock
      gnomeExtensions.gsconnect
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.tiling-assistant
      gnomeExtensions.caffeine
      
      pkgs.dracula-theme
      pkgs.adw-gtk3
    ];
  };

  virtualisation.docker.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    firefox
    wget
    xdg-utils
    git    
    tldr
    xdg-desktop-portal-gnome
    libreoffice
    vlc
    tldr
    kooha
    gamescope
    pkgs.vscode
    pkgs.docker
    pkgs.nodejs
    pkgs.python311
    pkgs.python310
    pkgs.virtualenv
    pkgs.zlib    
    pkgs.gcc
    pkgs.docker-compose
    pkgs.cmake
    pkgs.gnumake

    pavucontrol
  ];

  programs.steam.enable = true;

programs.kdeconnect.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
