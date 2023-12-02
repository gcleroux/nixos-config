{ pkgs, config, lib, ... }: {
  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-local
      mopidy-spotify
      mopidy-mpd
      mopidy-mpris
    ];
    settings = {
      local = {
        enabled = true;
        media_dir = "${config.home.homeDirectory}/Music";
        scan_follow_symlinks = true;
        excluded_file_extensions = [ ".html" ".zip" ".jpg" ".jpeg" ".png" ];
      };
      mpd = {
        enabled = true;
        hostname = "127.0.0.1";
        port = "6600";
      };
      spotify = {
        enabled = true;
        username =
          builtins.readFile "${config.sops.secrets.spotify_username.path}";
        password =
          builtins.readFile "${config.sops.secrets.spotify_password.path}";
        client_id =
          builtins.readFile "${config.sops.secrets.spotify_client_id.path}";
        client_secret =
          builtins.readFile "${config.sops.secrets.spotify_client_secret.path}";
        allow_cache = true;
        cache_size = 0; # Unlimited
      };
    };
  };

  sops = {
    secrets = {
      spotify_username.sopsFile = ./credentials.yaml;
      spotify_password.sopsFile = ./credentials.yaml;
      spotify_client_id.sopsFile = ./credentials.yaml;
      spotify_client_secret.sopsFile = ./credentials.yaml;
    };
  };
}
