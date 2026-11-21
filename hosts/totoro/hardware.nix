{ config, ... }:
{
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  hardware.cpu.amd.updateMicrocode = true;

  # RTX 2080 (Turing): NVIDIA's driver, for NVENC and Vulkan
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # NVIDIA's recommended kernel modules from Turing on
    open = true;
    # Sunshine's KMS capture needs it
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
}
