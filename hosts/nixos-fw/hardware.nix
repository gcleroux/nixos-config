{ lib, pkgs, ... }:
{
  boot = {
    loader.systemd-boot.configurationLimit = 50;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "quiet"
      "splash"
    ];
    extraModprobeConfig = "options kvm_intel nested=1";

    supportedFilesystems = [ "nfs" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      luks.devices."root".device = "/dev/disk/by-uuid/dbed6eea-7331-4610-b531-4f78b063fb1a";
    };
    tmp.cleanOnBoot = true;
  };

  hardware = {
    bluetooth.enable = true;
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
    opentabletdriver.enable = true;
    opentabletdriver.daemon.enable = true;
    logitech.wireless.enable = true;
  };

  networking.useDHCP = lib.mkDefault true;

  services = {
    # Since dock is TB3, it doesn't support wake-from-USB.
    # Ignoring lidSwitch events will prevent laptop from going to sleep
    # and thus having to reopen the lid since external devices are connected to the dock
    hardware.bolt.enable = true;
    logind.settings.Login.HandleLidSwitchDocked = "ignore";
  };
}
