{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "no";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };

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
