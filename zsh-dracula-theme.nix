{ pkgs, ... }:
let
  dracula-theme = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "zsh";
    rev = "a3e27d47ea2ed1e3b435f44aa71caf71d3219af6";
    sha256 = "sha256-unPUH3D89gH0j8/kv1Dl+ybR5n8UX0hJ+SuETtgpJOo=";
  };

  zsh-customs = pkgs.stdenv.mkDerivation {
    name = "zsh-customs";

    phases = [ "buildPhase" ];
    buildPhase = ''
      mkdir -p $out/themes
      cp ${dracula-theme}/dracula.zsh-theme $out/themes
      cp -r ${dracula-theme}/lib $out/themes

      # mkdir -p $out/plugins
      # cp -r $ {fast-syntax-highlighting} $out/plugins/fast-syntax-highlighting
      # cp -r $ {fzf-tab} $out/plugins/fzf-tab
    '';
  };
in
{
  programs.zsh = {
    ohMyZsh = {
      # Expanded at shell startup: per-user override via ZSH_USER_THEME
      theme = "\${ZSH_USER_THEME:-dracula}";
      custom = "${zsh-customs}";
    };
  };
}
