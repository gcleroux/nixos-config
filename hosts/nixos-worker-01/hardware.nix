{ pkgs, ... }:
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

  hardware = {
    cpu.intel.updateMicrocode = true;

    # GPU hardware acceleration
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        libvdpau-va-gl
        vpl-gpu-rt
      ];
    };
  };
  services.hardware.bolt.enable = true;
}
