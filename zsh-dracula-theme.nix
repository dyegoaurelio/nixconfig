{ pkgs, ... }:
let
  dracula-theme = pkgs.fetchFromGitHub {
    owner = "dracula";
    repo = "zsh";
    rev = "75ea3f5e1055291caf56b4aea6a5d58d00541c41";
    sha256 = "sha256-TuKC1wPdq2OtEeViwnAmitpdaanyXHJmBcqV+rHxy34=";
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
      theme = "dracula";
      custom = "${zsh-customs}";
    };
  };
}
