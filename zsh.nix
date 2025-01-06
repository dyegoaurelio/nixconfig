{ config, pkgs, ... }:

  {
  environment.systemPackages = with pkgs; [
    thefuck # zsh plugin
    zoxide # smarter cd
    fzf # fuzzy finder used by zoxide
  ];

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    # autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "thefuck" "golang" "zoxide" "yarn" ];
    };
    interactiveShellInit = ''
        source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
        source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh


        # make down arrow key go to the menu  
        # (needs to be at .zshrc)
        # bindkey  "$terminfo[kcud1]"  menu-select

        # Make Tab and ShiftTab go to the menu
        # bindkey              '^I' menu-select
        # bindkey "$terminfo[kcbt]" menu-select

        # Make Tab and ShiftTab cycle through the menu
        # bindkey -M menuselect              '^I'         menu-complete
        # bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete
      '';
  };

  imports = [
    ./zsh-dracula-theme.nix
  ];

  }