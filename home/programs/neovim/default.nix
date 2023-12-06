{ pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      markdown-preview-nvim
      vim-markdown-toc
      go-nvim
    ];

    extraPackages = with pkgs; [
      # Debugger
      delve

      # Installing tools
      cargo
      luajitPackages.luarocks
      nodePackages.npm
      nodejs-slim_20

      # Tools packages (Comes with a bunch of stuff)
      clang-tools
      gotools
      reftools
      ginkgo
      richgo
      gotestsum
      govulncheck

      # LSP packages
      docker-compose-language-service
      gopls
      lua-language-server
      marksman
      nil
      nodePackages.bash-language-server
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.vscode-html-languageserver-bin
      nodePackages.vscode-json-languageserver-bin
      nodePackages.yaml-language-server
      python311Packages.jedi-language-server
      quick-lint-js
      taplo

      # Linters
      codespell
      cpplint
      deadnix
      golangci-lint
      hadolint
      luajitPackages.luacheck
      nodePackages.markdownlint-cli
      pylint
      python311Packages.flake8
      shellcheck
      statix
      yamllint

      # Formatters
      black
      cbfmt
      gofumpt
      isort
      nixfmt
      nodePackages.prettier
      shfmt
      stylua
      golines

      # Code actions
      gomodifytags
      gotests
      impl
      iferr
    ];
  };
}
