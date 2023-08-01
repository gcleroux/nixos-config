  { pkgs, ... }:
  {
    programs.neovim = {
      enable = true;
      defaultEditor = true;

      extraPackages = with pkgs; [
        # Tools packages (Comes with a bunch of stuff)
        clang-tools
        gotools

        # LSP packages
        gopls
        lua-language-server
        marksman
        nil
        nodePackages.bash-language-server
        nodePackages.dockerfile-language-server-nodejs
        nodePackages.vscode-html-languageserver-bin
        nodePackages.vscode-json-languageserver-bin
        nodePackages.yaml-language-server
        python311Packages.jedi
        taplo

        # Linters
        codespell
        cpplint
        golangci-lint
        hadolint
        luajitPackages.luacheck
        nodePackages.markdownlint-cli
        pylint
        python311Packages.flake8
        shellcheck

        # Formatters
        black
        isort
        nodePackages.prettier
        shfmt
        stylua
      ];
    };
  }

