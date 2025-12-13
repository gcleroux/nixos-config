{
  imports = [
    ./configuration.nix
    ./hardware.nix
    ./disks.nix
    ./interfaces.nix
    ./firewall.nix

    ./services/blocky.nix
    ./services/dnsmasq.nix
    ./services/unbound.nix
  ];
}
