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

  # deploy-rs logs in as root: key only, from the LAN or nixos-fw's VPN address
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  users.users.root.openssh.authorizedKeys.keys = [
    ''from="10.0.0.0/24,2606:6d00:ffb:6600::/64,10.0.9.101,2606:6d00:ffb:6609::101" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICS77iyKWFPGfozY/N0daz6d9uEXhpdSVpsTTIkBbcRg guillaume@nixos-fw''
  ];

  environment = {
    # Installed packages
    systemPackages = with pkgs; [
      bottom
      btrbk
      foot.terminfo
      git
      gptfdisk
      iputils
      neovim
      pciutils
      powerstat
      usbutils
      wget
    ];
  };

  system.stateVersion = "25.11";
}
