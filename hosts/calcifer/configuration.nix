{
  inputs,
  config,
  pkgs,
  username,
  hostname,
  outputs,
  ...
}:
{
  host.users.guillaume.admin = true;

  services.resolved.enable = false;

  # deploy-rs logs in as root: key only, from the LAN or nixos-fw's VPN address
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  users.users.root.openssh.authorizedKeys.keys = [
    ''from="10.0.0.0/24,2606:6d00:ffb:6600::/64,10.0.9.101,2606:6d00:ffb:6609::101" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICS77iyKWFPGfozY/N0daz6d9uEXhpdSVpsTTIkBbcRg guillaume@nixos-fw''
  ];

  programs = {
    fish.enable = true;
    mtr.enable = true;
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      bottom
      conntrack-tools
      dnsutils
      ethtool
      foot
      git
      iputils
      neovim
      pciutils
      powerstat
      tcpdump
      traceroute
      usbutils
      wget
    ];
  };

  system.stateVersion = "25.05";
}
