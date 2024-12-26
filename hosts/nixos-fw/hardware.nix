{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Kernel config
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [
      "mem_sleep_default=deep"
      "quiet"
      "splash"
    ];
    extraModprobeConfig = "options kvm_intel nested=1";

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
      luks.devices."root".device = "/dev/disk/by-uuid/dbed6eea-7331-4610-b531-4f78b063fb1a";
      systemd.enable = true;
    };
    tmp.cleanOnBoot = true;
  };

  hardware = {
    bluetooth.enable = true;

    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # GPU hardware acceleration
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
        libvdpau-va-gl
      ];
    };
    opentabletdriver.enable = true;
    opentabletdriver.daemon.enable = true;
    logitech.wireless.enable = true;
    logitech.wireless.enableGraphical = true;
  };

  networking.useDHCP = lib.mkDefault true;
}
