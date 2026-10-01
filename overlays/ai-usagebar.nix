# ai-usagebar: AI plan usage in the terminal, Waybar, and the GNOME top panel.
#   https://github.com/akitaonrails/ai-usagebar
#
# Not in nixpkgs yet, so this file packages it. It has three parts:
#   1. the pinned upstream source,
#   2. the package functions, written in nixpkgs `package.nix` style,
#   3. the overlay that wires them into pkgs.
#
# The CLI reuses upstream's own `nix/package.nix`, which is what their flake's
# `overlays.default` calls, so we don't keep a second copy of the recipe. It
# also reads Cargo.lock directly, so there's no cargoHash to update. Only the
# GNOME extension is defined here, because upstream doesn't package it.
#
# To bump: set `version`, then set `hash` to lib.fakeHash (or run
#   nix-prefetch-url --unpack <archive url>) and copy the hash nix reports.
let
  # --- 1. Source ------------------------------------------------------------

  version = "1.30.0";

  # This is an eval-time fetch rather than fetchFromGitHub because we import a
  # .nix file from it. Importing from a build output would be
  # import-from-derivation. Both fetchers produce the same NAR hash, so the
  # value can be copied as-is if this ever moves to fetchFromGitHub.
  src = builtins.fetchTarball {
    name = "source";
    url = "https://github.com/akitaonrails/ai-usagebar/archive/refs/tags/v${version}.tar.gz";
    sha256 = "sha256:0zdkd4sf0jh2w0clgy4ggjh3inhk711vs570j65pb1cfhs3a4xhr";
  };

  # --- 2. Packages ----------------------------------------------------------

  # The binaries: ai-usagebar and ai-usagebar-tui.
  ai-usagebar = import "${src}/nix/package.nix";

  # The GNOME Shell extension. It runs the CLI, so the lookup is patched to
  # use the Nix store path. The "Binary path" preference still overrides it.
  #
  # For nixpkgs, this would become
  # pkgs/desktops/gnome/extensions/ai-usagebar/package.nix, with `src`
  # replaced by `ai-usagebar.src` or a fetchFromGitHub call.
  gnome-shell-extension-ai-usagebar =
    {
      lib,
      stdenvNoCC,
      glib,
      ai-usagebar,
      src,
    }:

    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "gnome-shell-extension-ai-usagebar";
      inherit (ai-usagebar) version;
      inherit src;

      sourceRoot = "source/gnome-extension";

      nativeBuildInputs = [ glib ];

      postPatch = ''
        substituteInPlace extension.js \
          --replace-fail "GLib.find_program_in_path('ai-usagebar')" \
                         "'${lib.getExe ai-usagebar}'"
        substituteInPlace extension.js prefs.js \
          --replace-fail "GLib.find_program_in_path('ai-usagebar-tui')" \
                         "'${lib.getExe' ai-usagebar "ai-usagebar-tui"}'"
      '';

      buildPhase = ''
        runHook preBuild
        glib-compile-schemas --strict schemas
        runHook postBuild
      '';

      # Install only what GNOME Shell loads. Leave out the node tests,
      # package.json, the dev install.sh, and the READMEs.
      installPhase = ''
        runHook preInstall
        dest="$out/share/gnome-shell/extensions/${finalAttrs.passthru.extensionUuid}"
        install -Dm644 -t "$dest" metadata.json stylesheet.css
        find . -maxdepth 1 -name '*.js' -exec install -Dm644 -t "$dest" {} +
        install -Dm644 -t "$dest/icons" icons/*.svg
        install -Dm644 -t "$dest/schemas" schemas/*
        runHook postInstall
      '';

      passthru = {
        # This is the attribute that home-manager's programs.gnome-shell and
        # nixpkgs' gnomeExtensions tooling use to find the extension.
        extensionUuid = "ai-usagebar@akitaonrails.github.io";
      };

      meta = {
        description = "GNOME Shell top-panel indicator for ai-usagebar (AI plan usage)";
        homepage = "https://github.com/akitaonrails/ai-usagebar/tree/main/gnome-extension";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
      };
    });
in

# --- 3. Overlay -------------------------------------------------------------

final: prev: {
  ai-usagebar = final.callPackage ai-usagebar { };

  gnomeExtensions = prev.gnomeExtensions // {
    ai-usagebar = final.callPackage gnome-shell-extension-ai-usagebar { inherit src; };
  };
}
