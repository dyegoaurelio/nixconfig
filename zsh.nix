{ config, pkgs, ... }:

  {
  environment.systemPackages = with pkgs; [
    thefuck # zsh plugin
    zoxide # zsh plugin
  ];

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "thefuck" "golang" "zoxide"];
    };
  };

  imports = [
    ./zsh-dracula-theme.nix
  ];

  }