{
  services.gromit-mpx = {
    enable = false; # TODO: Gromit-mpx and river aren't playing well together
    hotKey = "F9";
    undoKey = "F10";

    tools = [
      {
        color = "red";
        device = "default";
        size = 5;
        type = "pen";
      }
      {
        color = "green";
        device = "default";
        modifiers = [ "1" ];
        size = 5;
        type = "pen";
      }
      {
        color = "blue";
        device = "default";
        modifiers = [ "2" ];
        size = 5;
        type = "pen";
      }
      {
        color = "yellow";
        device = "default";
        modifiers = [ "3" ];
        size = 5;
        type = "pen";
      }
      {
        arrowSize = 1;
        color = "green";
        device = "default";
        modifiers = [ "4" ];
        size = 6;
        type = "pen";
      }
      {
        device = "default";
        modifiers = [ "SHIFT" ];
        size = 75;
        type = "eraser";
      }
    ];
  };
}
