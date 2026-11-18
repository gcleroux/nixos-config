{ pkgs, ... }:
{
  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
      ];
    };
    # libvirt's VMs get DHCP and DNS from the host on virbr0
    firewall.trustedInterfaces = [ "virbr0" ];
  };
}
