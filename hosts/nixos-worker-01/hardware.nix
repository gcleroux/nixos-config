{
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-intel" ];
  };

  # No hardware.graphics: the kernel driver gives Jellyfin /dev/dri, and its image brings the drivers
  hardware.cpu.intel.updateMicrocode = true;
  services.hardware.bolt.enable = true;
}
