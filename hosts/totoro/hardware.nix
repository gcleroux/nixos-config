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
        configurationLimit = 10;
      };
      efi.canTouchEfiVariables = true;
    };
    # Kernel config
    kernelModules = [ ];
    kernelParams = [
      "quiet"
      "splash"
    ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
      systemd.enable = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;

    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
