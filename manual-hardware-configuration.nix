{ config, pkgs, ... }:

{

  # Setup keyfile
#  boot.initrd.secrets = {
#    "/crypto_keyfile.bin" = null;
#  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  ## limit generations number (avoid filling up boot partition)
  boot.loader.systemd-boot.configurationLimit = 5;


  # Enable networking
  networking.networkmanager.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;


  # xbox controller support
  environment.systemPackages = with pkgs; [
    linuxKernel.packages.linux_zen.xpadneo
    linuxKernel.packages.linux_zen.system76
  ];

  hardware.xpadneo.enable = true;


}
