{
  # Hourly snapshots of @. Only includes /var/lib,
  #  /etc, /tmp, /root and /srv
  services.btrbk = {
    instances.snapshots = {
      onCalendar = "hourly";
      settings = {
        timestamp_format = "long-iso";
        snapshot_preserve_min = "2d";
        snapshot_preserve = "14d 4w";
        volume."/mnt/btr_pool" = {
          snapshot_dir = "@snapshots";
          subvolume."@".snapshot_name = "root";
        };
      };
    };

    # totoro's btrbk SSH key, can only read the snapshots
    sshAccess = [
      {
        key = builtins.readFile ../../totoro/services/backups/ssh_key.pub;
        roles = [ "send" ];
        extraArgs = [
          "--restrict-path"
          "/mnt/btr_pool/@"
          "--restrict-path"
          "/mnt/btr_pool/@snapshots"
        ];
      }
    ];
  };
  services.openssh.extraConfig = ''
    Match User btrbk
      DisableForwarding yes
      PermitTTY no
  '';
}
