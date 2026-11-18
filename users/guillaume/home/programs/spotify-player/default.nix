{
  programs.spotify-player = {
    enable = true;
    settings = {
      theme = "default";
      client_id = "3c3b27b625bc4d6bb067bbc3dcd920e0";
      client_port = 8800;
      playback_format = ''
        {track} • {artists}
        {album}
        {metadata}
      '';
      tracks_playback_limit = 50;
      app_refresh_duration_in_ms = 32;
      playback_refresh_duration_in_ms = 0;
      cover_image_refresh_duration_in_ms = 2000;
      page_size_in_rows = 20;
      play_icon = "▶";
      pause_icon = "▌▌";
      liked_icon = "♥";
      border_type = "Plain";
      progress_bar_type = "Rectangle";
      playback_window_position = "Top";
      cover_img_length = 9;
      cover_img_width = 5;
      cover_img_scale = 3.0;
      playback_window_width = 6;
      enable_media_control = true;
      notify_streaming_only = true;
      enable_streaming = "DaemonOnly";
      enable_cover_image_cache = true;
      default_device = "spotify-player";

      copy_command = {
        command = "wl-copy";
        args = [ ];
      };

      notify_format = {
        summary = "{track} • {artists}";
        body = "{album}";
      };

      device = {
        name = "spotify-player";
        device_type = "speaker";
        volume = 100;
        bitrate = 320;
        audio_cache = false;
        normalization = true;
      };
    };
  };
}
