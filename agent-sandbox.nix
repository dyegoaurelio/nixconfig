{ config, pkgs, ... }:

{
  # Isolated user for running AI agents. Deliberately NOT in wheel, docker,
  # or networkmanager — no sudo and no root-equivalent docker socket access.
  users.groups.agent = { };
  users.users.agent = {
    isNormalUser = true;
    description = "agent sandbox";
    group = "agent";
    extraGroups = [ ];
    # Group-readable so dyego (member of "agent") can inspect the agent's home.
    homeMode = "750";
    packages = with pkgs; [
      pkgs-unstable.claude-code
      pkgs-unstable.ghostty.terminfo

      bat
      nixfmt
    ];
  };

  # dyego can read agent's home; agent cannot read dyego's.
  users.users.dyego = {
    extraGroups = [ "agent" ];
    homeMode = "700";
  };
}
