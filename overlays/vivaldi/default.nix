{ pkgs, config, lib, ... }:
(self: super: {
  # Vivaldi with hardware acceleration
  vivaldi = super.vivaldi.override {
    proprietaryCodecs = true;
    enableWidevine = false;
  };
})
