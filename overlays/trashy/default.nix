{
  pkgs,
  config,
  lib,
  ...
}:
# Fetch the latest version of trashy to fix zsh completions
# https://github.com/oberblastmeister/trashy/pull/103
(self: super: {
  trashy-zsh-fix = super.trashy.overrideAttrs (old: rec {
    pname = "trashy";
    version = "v2.0.0";

    src = super.fetchFromGitHub {
      owner = "oberblastmeister";
      repo = "trashy";
      rev = "7c48827e55bca5a3188d3de44afda3028837b34b";
      hash = "sha256-1pxmeXUkgAITouO0mdW6DgZR6+ai2dax2S4hV9jcJLM=";
    };

    cargoDeps = old.cargoDeps.overrideAttrs (
      super.lib.const {
        name = "${pname}-vendor.tar.gz";
        inherit src;
        outputHash = "sha256-2QITAwh2Gpp+9JtJG77hcXZ5zhxwNztAtdfLmPH4J3Y=";
      }
    );

    preFixup = ''
      installShellCompletion --cmd trashy \
        --bash <($out/bin/trashy completions bash) \
        --fish <($out/bin/trashy completions fish) \
        --zsh <($out/bin/trashy completions zsh) \
    '';
  });
})
