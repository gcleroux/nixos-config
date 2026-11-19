{
  boot = {
    kernelModules = [ "kvm-intel" ];
    kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      # "net.ipv4.conf.default.rp_filter" = 1;

      # Unbound tweaks
      "net.core.rmem_max" = 4194304;
      "net.core.wmem_max" = 4194304;
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
  };

  hardware.cpu.intel.updateMicrocode = true;
}
