{ config, pkgs, ... }:

{
    fileSystems."/data/ssd_extra" =
  { device = "/dev/disk/by-label/Files";
    fsType = "ext4";
  };




## NVIDEA CONFIG

 # Make sure opengl is enabled
# hardware.opengl = {
#   enable = true;
#   driSupport = true;
#   driSupport32Bit = true;
#   extraPackages = with pkgs; [
#     vulkan-loader
#     vulkan-validation-layers
#     vulkan-extension-layer
#   ];
# };

#   # Tell Xorg to use the nvidia driver (also valid for Wayland)
#   services.xserver.videoDrivers = ["nvidia"];
  
#   hardware.nvidia = {

#    forceFullCompositionPipeline = true;

# #Fix graphical corruption on suspend/resume
#    powerManagement.enable = true;

#     # Modesetting is needed for most Wayland compositors
# # (uncomment to use wayland)
#     modesetting.enable = true;

#     # Use the open source version of the kernel module
#     # Only available on driver 515.43.04+
#     open = false;

#     # Enable the nvidia settings menu
#     nvidiaSettings = true;

#     # Optionally, you may need to select the appropriate driver version for your specific GPU.
#     package = config.boot.kernelPackages.nvidiaPackages.stable;

#   };

## END OF NVIDEA CONFIG
}
