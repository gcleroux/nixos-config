{ pkgs, ... }:
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

    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
    ];
    tmp.cleanOnBoot = true;
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
    opentabletdriver.enable = true;
    logitech.wireless.enable = true;
  };

  services = {
    hardware.bolt.enable = true;

    # Built-in keyboard only (atkbd; USB keyboards like the Defy never match): swap left
    # Ctrl and left Alt. The right-hand keys stay, right Alt is EurKEY's AltGr.
    udev.extraHwdb = ''
      evdev:atkbd:*
       KEYBOARD_KEY_1d=leftalt
       KEYBOARD_KEY_38=leftctrl
    '';

    # The TB3 dock can't wake the laptop over USB: stay awake with the lid closed while
    # docked, instead of suspending until the lid is reopened
    logind.settings.Login.HandleLidSwitchDocked = "ignore";
  };
}
