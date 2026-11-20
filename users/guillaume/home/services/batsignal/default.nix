{
  # One notification at 20%, a critical one at 10%
  services.batsignal = {
    enable = true;
    extraArgs = [
      "-w"
      "20"
      "-c"
      "10"
    ];
  };

  # Lives and restarts with dunst. libnotify caches the notification daemon's bus
  # address, and batsignal runs no GLib main loop to learn of a new one, so after a
  # dunst restart its notifications would silently go nowhere.
  systemd.user.services.batsignal = {
    Unit = {
      BindsTo = [ "dunst.service" ];
      After = [ "dunst.service" ];
    };
    Install.WantedBy = [ "dunst.service" ];
  };
}
