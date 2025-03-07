{
  programs.ssh = {
    enable = true;
    includes = [
      "hosts/pinax"
      "hosts/homelab"
    ];
  };

  sops.secrets.pinax_ssh_hosts = {
    sopsFile = ./hosts/pinax;
    path = ".ssh/hosts/pinax";
    mode = "0400";
    format = "binary";
  };

  sops.secrets.homelab_ssh_hosts = {
    sopsFile = ./hosts/homelab;
    path = ".ssh/hosts/homelab";
    mode = "0400";
    format = "binary";
  };

  # Personal SSH key
  sops.secrets.id_ed25519 = {
    sopsFile = ./keys/id_ed25519;
    path = ".ssh/id_ed25519";
    mode = "0400";
    format = "binary";
  };
  home.file.".ssh/id_ed25519.pub" = {
    source = ./keys/id_ed25519.pub;
  };

  # Pinax SSH key
  sops.secrets.pinax_key = {
    sopsFile = ./keys/pinax_key;
    mode = "0400";
    path = ".ssh/pinax_key";
    format = "binary";
  };
  home.file.".ssh/pinax_key.pub" = {
    source = ./keys/pinax_key.pub;
  };
}
