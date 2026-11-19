{
  # Snapshots of /home: every day, kept 14 days, then weekly for 5 weeks and monthly for 3 months
  services.btrbk.instances.home = {
    onCalendar = "daily";
    settings = {
      snapshot_preserve_min = "7d";
      snapshot_preserve = "14d 5w 3m";
      volume."/" = {
        snapshot_dir = "/.snapshots/home";
        subvolume.home.snapshot_create = "always";
      };
    };
  };
  systemd.tmpfiles.rules = [ "d /.snapshots/home 0755 root root -" ];
}
