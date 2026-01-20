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
      systemd-boot = {
        enable = true;
        configurationLimit = 50;
      };
      efi.canTouchEfiVariables = true;
    };
    # Kernel config
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
      kernelModules = [ ];
      luks.devices."root".device = "/dev/disk/by-uuid/dbed6eea-7331-4610-b531-4f78b063fb1a";
      systemd.enable = true;
    };
    tmp.cleanOnBoot = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    bluetooth.enable = true;

    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

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
    logitech.wireless.enableGraphical = true;
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
