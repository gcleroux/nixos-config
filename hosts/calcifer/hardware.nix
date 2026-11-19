{
  boot = {
    kernelModules = [ "kvm-intel" ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
  };

  hardware.cpu.intel.updateMicrocode = true;
}
