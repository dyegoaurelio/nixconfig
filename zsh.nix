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
    # enableCompletion = true;
    enableCompletion = false;
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
      '';
  };

  imports = [
    ./zsh-dracula-theme.nix
  ];

  }