{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Never forward the agent, unless a host in the includes (read first) asks for it
    settings."*".ForwardAgent = false;

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
}
