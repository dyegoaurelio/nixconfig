{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Official WiFi firmware from Sean Wang's linux-firmware submission (version 20251212)
  # https://lore.kernel.org/linux-wireless/20260219193751.5823-1-sean.wang@kernel.org/
  # BT firmware: no official submission yet, using OnlineLearningTutorials/mt7902_temp
  mt7902-firmware = pkgs.stdenvNoCC.mkDerivation {
    pname = "mt7902-firmware";
    version = "20251212";
    src = ./firmware/mt7902;
    btSrc = pkgs.fetchFromGitHub {
      owner = "OnlineLearningTutorials";
      repo = "mt7902_temp";
      rev = "7c6b76d4f719a19a6c2f59bac1f9ff6cbe0d54b6";
      hash = "sha256-DN79N4SAzm49kTkdvwoyaT7blwuyNQjOdjlCTkPlRzU=";
    };
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/firmware/mediatek
      cp WIFI_RAM_CODE_MT7902_1.bin        $out/lib/firmware/mediatek/
      cp WIFI_MT7902_patch_mcu_1_1_hdr.bin $out/lib/firmware/mediatek/
      cp $btSrc/mt7902_firmware/BT_RAM_CODE_MT7902_1_1_hdr.bin $out/lib/firmware/mediatek/
      runHook postInstall
    '';
  };
in
{
  # Override kernel to 6.18.13 (latest 6.18 LTS)
  boot.kernelPackages = lib.mkForce (
    pkgs.linuxPackagesFor (
      pkgs.linux_latest.override {
        argsOverride = rec {
          version = "6.18.13";
          modDirVersion = version;
          src = pkgs.fetchurl {
            url = "mirror://kernel/linux/kernel/v6.x/linux-${version}.tar.xz";
            hash = "sha256-7Sw8Vf045oNsCU/ONW8lZ/lRYTC3M1SimFeWA2jFaH8=";
          };
        };
      }
    )
  );

  boot.kernelPatches = [
    # Preparatory patches to align 6.18.x code with the upstream tree
    # the MT7902 series targets
    {
      name = "mt7902-prep-01-pci-extract-regs-variable";
      patch = ./kernel-patches/mt7902/prep-01-pci-extract-regs-variable.patch;
    }
    {
      name = "mt7902-prep-02-remove-chanctx-sta-csa-check";
      patch = ./kernel-patches/mt7902/prep-02-remove-chanctx-sta-csa-check.patch;
    }

    # MT7902 patch series by Sean Wang <sean.wang@mediatek.com>
    # https://lore.kernel.org/linux-wireless/20260219004007.19733-1-sean.wang@kernel.org/
    {
      name = "mt7902-01-connac-use-is_connac2";
      patch = ./kernel-patches/mt7902/01-connac-use-is_connac2.patch;
    }
    {
      name = "mt7902-02-mt7921-use-mt76_for_each_q_rx";
      patch = ./kernel-patches/mt7902/02-mt7921-use-mt76_for_each_q_rx.patch;
    }
    {
      name = "mt7902-03-mt7921-irq-map-quirk";
      patch = ./kernel-patches/mt7902/03-mt7921-handle-mt7902-irq-map-quirk.patch;
    }
    {
      name = "mt7902-04-mt7921-dma-layout";
      patch = ./kernel-patches/mt7902/04-mt7921-add-mt7902e-dma-layout.patch;
    }
    {
      name = "mt7902-05-connac-mark-hw-txp";
      patch = ./kernel-patches/mt7902/05-connac-mark-mt7902-hw-txp.patch;
    }
    {
      name = "mt7902-06-mt792x-pse-barrier";
      patch = ./kernel-patches/mt7902/06-mt792x-pse-handling-barrier.patch;
    }
    {
      name = "mt7902-07-mt792x-ensure-mcu-ready";
      patch = ./kernel-patches/mt7902/07-mt792x-ensure-mcu-ready.patch;
    }
    {
      name = "mt7902-08-mt7921-mcu-support";
      patch = ./kernel-patches/mt7902/08-mt7921-add-mt7902-mcu-support.patch;
    }
    {
      name = "mt7902-09-mt792x-wfdma-prefetch";
      patch = ./kernel-patches/mt7902/09-mt792x-mt7902-wfdma-prefetch.patch;
    }
    {
      name = "mt7902-10-mt7921-pcie";
      patch = ./kernel-patches/mt7902/10-mt7921-add-mt7902-pcie.patch;
    }
    {
      name = "mt7902-11-mt7921-sdio";
      patch = ./kernel-patches/mt7902/11-mt7921-add-mt7902-sdio.patch;
    }
  ];

  hardware.firmware = [ mt7902-firmware ];

  assertions = [
    {
      assertion = lib.versionOlder pkgs.linux_latest.version "7.1";
      message = "nixpkgs default kernel (${pkgs.linux_latest.version}) likely includes MT7902 support upstream. Consider removing mt7902.nix.";
    }
  ];
}
