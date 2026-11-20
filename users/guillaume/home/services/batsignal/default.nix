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
}
