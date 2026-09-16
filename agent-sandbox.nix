{
  lib,
  pkgs,
  ...
}:

let
  # Isolated users for running AI agents. Deliberately NOT in wheel, docker,
  # or networkmanager — no sudo and no root-equivalent docker socket access.
  agents = {
    agent = "agent sandbox (work)";
  };

  mkAgent = name: description: {
    isNormalUser = true;
    inherit description;
    group = name;
    extraGroups = [ ];
    # Group-readable so dyego (member of every agent group) can inspect the home.
    homeMode = "750";
    packages = with pkgs; [
      pkgs-unstable.claude-code
      pkgs-unstable.ghostty.terminfo

      bat
      nixfmt
    ];
  };

  agent-coown-script = pkgs.writeShellApplication {
    name = "agent-coown";
    runtimeInputs = with pkgs; [
      acl
      coreutils
      findutils
    ];
    text = /* bash */ ''
      # Give dyego "co-ownership" of an agent working tree: full rw for both
      # users on everything in it, plus default ACLs so files created later
      # inherit the grant. Idempotent — rerun any time, e.g. after tools
      # recreate files.
      agents=(${lib.concatStringsSep " " (lib.attrNames agents)})

      usage() {
        echo "usage: agent-coown DIR AGENT" >&2
        echo "  AGENT  one of: ${lib.concatStringsSep " " (lib.attrNames agents)}" >&2
        echo "  DIR    a directory under /tmp or under an agent home." >&2
        echo "         Outside AGENT's own home it asks before granting." >&2
      }

      # Both arguments are required. DIR is spelled out rather than defaulted to
      # $PWD: "." costs one character and cannot be typed by accident.
      if [ $# -ne 2 ]; then
        usage
        exit 2
      fi

      dir=$(realpath -- "$1")
      agent=$2

      if [ ! -d "$dir" ]; then
        echo "agent-coown: $dir is not a directory" >&2
        exit 1
      fi

      # Only ever hand out access to a declared sandbox. Granting dyego rw is
      # harmless, but the second half of the grant is rw for "$agent" — an
      # unchecked name here would open the tree to any account on the box.
      case " ''${agents[*]} " in
        *" $agent "*) ;;
        *)
          echo "agent-coown: $agent is not an agent sandbox user" >&2
          usage
          exit 1
          ;;
      esac

      # Scratch space and agent homes are the only trees that may be opened up.
      # Everything else — /home/dyego, /etc/nixos, a mounted share — is dyego's
      # alone, and no typo should be able to hand an agent write access to it.
      home_of=
      for candidate in "''${agents[@]}"; do
        case $dir in
          "/home/$candidate" | "/home/$candidate"/*)
            home_of=$candidate
            break
            ;;
        esac
      done

      case $dir in
        /tmp | /tmp/*) in_scratch=true ;;
        *) in_scratch=false ;;
      esac

      if [ -z "$home_of" ] && [ "$in_scratch" = false ]; then
        echo "agent-coown: refusing $dir" >&2
        echo "  only /tmp and the agent homes may be co-owned" >&2
        exit 1
      fi

      # Inside the agent's own home this is routine. Anywhere else it crosses a
      # boundary — another agent's home, or shared scratch — so say which one
      # and make it a deliberate answer.
      if [ "$home_of" != "$agent" ]; then
        if [ -n "$home_of" ]; then
          why="$dir belongs to $home_of, not to $agent"
        else
          why="$dir is shared scratch space, outside $agent's home"
        fi

        if [ ! -t 0 ]; then
          echo "agent-coown: $why" >&2
          echo "  refusing: this needs an interactive confirmation" >&2
          exit 1
        fi

        printf 'agent-coown: %s.\nGrant %s read+write on it anyway? [y/N] ' "$why" "$agent"
        read -r reply
        case $reply in
          [yY] | [yY][eE][sS]) ;;
          *)
            echo "agent-coown: aborted" >&2
            exit 1
            ;;
        esac
      fi

      # root, not sudo -u "$agent": the tree may contain files created by
      # either user, and only root can setfacl across mixed ownership.
      sudo setfacl -R -m "u:dyego:rwX,u:$agent:rwX" "$dir"
      sudo find "$dir" -type d -exec setfacl -m "d:u:dyego:rwX,d:u:$agent:rwX" {} +

      # The setfacl calls are what we asked for; this is whether it worked.
      # An ancestor dyego cannot traverse, an immutable bit or a restrictive
      # mask all defeat the grant silently, so ask the kernel with access(2)
      # as dyego instead of trusting it. Symlinks are skipped — a dangling
      # one is unreadable by everybody.
      mapfile -t unreachable < <(
        sudo -u dyego find "$dir" ! -type l \( ! -readable -o ! -writable \) -print 2>/dev/null
      )

      if [ ''${#unreachable[@]} -gt 0 ]; then
        echo "agent-coown: dyego still lacks read+write on:" >&2
        printf '  %s\n' "''${unreachable[@]}" >&2
        exit 1
      fi

      echo "agent-coown: dyego and $agent co-own $dir"
    '';
  };

  agent-coown = pkgs.symlinkJoin {
    name = "agent-coown";
    paths = [
      agent-coown-script
      (pkgs.writeTextFile {
        name = "agent-coown-zsh-completion";
        destination = "/share/zsh/site-functions/_agent-coown";
        text = /* zsh */ ''
          #compdef agent-coown

          # Both arguments are required and both are drawn from a closed set,
          # which is most of the reason this file exists: the agent names are
          # not guessable and the valid roots are not the whole filesystem.
          _agent_coown_dir() {
            _alternative \
              'roots:co-ownable root:compadd -S / -- ${
                lib.concatStringsSep " " ([ "/tmp" ] ++ map (a: "/home/${a}") (lib.attrNames agents))
              }' \
              'directories:directory:_path_files -/'
          }

          _arguments -s -S \
            '1:directory:_agent_coown_dir' \
            '2:agent user:(${lib.concatStringsSep " " (lib.attrNames agents)})'
        '';
      })
    ];
  };
in
{
  users.groups = lib.genAttrs (lib.attrNames agents) (_: { });
  users.users = lib.mapAttrs mkAgent agents // {
    # dyego can read every agent home; no agent can read dyego's.
    dyego = {
      extraGroups = lib.attrNames agents;
      homeMode = "700";
      packages = [ agent-coown ];
    };
  };
}
