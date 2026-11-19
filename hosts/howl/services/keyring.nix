{
  # Unlocked at login: greetd's PAM stack includes login, which this module hooks
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
}
