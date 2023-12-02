{
  programs.ncmpcpp = {
    enable = true;
    bindings = [
      {
        key = "h";
        command = [ "previous_column" ];
      }
      {
        key = "h";
        command = [ "master_screen" ];
      }
      {
        key = "j";
        command = "scroll_down";
      }
      {
        key = "k";
        command = "scroll_up";
      }
      {
        key = "J";
        command = [ "select_item" "scroll_down" ];
      }
      {
        key = "K";
        command = [ "select_item" "scroll_up" ];
      }
      {
        key = "l";
        command = [ "next_column" ];
      }
      {
        key = "l";
        command = [ "slave_screen" ];
      }
    ];
    settings = {
      mpd_host = "127.0.0.1";
      mpd_port = "6600";
    };
  };
}
