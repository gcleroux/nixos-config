{ pkgs, config, lib, ... }:
(self: super: {
  # Vivaldi with hardware acceleration
  brave = super.brave.override {
    commandLineArgs = "--enable-features=TouchpadOverscrollHistoryNavigation";
  };
})

