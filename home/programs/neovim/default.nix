{ pkgs, config, ... }: {
  # TODO: Find a cleaner way to manage config
  xdg.configFile = {
    nvim = {
      recursive = true;
      source = ./config;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = ''
      -- Setup global config
      require("globals")

      -- Plugins config
      require("plugins")

      -- Set up the colorscheme (comes before ui)
      require("themes.onenord")

      -- Set up the UI
      require("ui")

      -- Debuggers config
      require("debuggers")

      -- Set up LSP (Should be loaded last)
      require("lsp")

      require("chatgpt").setup({
        api_key_cmd = "cat ${config.sops.secrets.chatgpt_key.path}"
      })
    '';

    plugins = with pkgs.vimPlugins; [
      popup-nvim
      plenary-nvim
      nvim-autopairs
      nvim-web-devicons
      bufferline-nvim
      vim-bbye
      rainbow-delimiters-nvim
      neogen
      nightfox-nvim
      onenord-nvim
      gitsigns-nvim
      lazygit-nvim
      suda-vim
      luasnip
      friendly-snippets
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp-cmdline
      cmp-nvim-lsp
      cmp-emoji
      cmp_luasnip
      cmp-dap
      lsp-zero-nvim
      null-ls-nvim
      nvim-lspconfig
      SchemaStore-nvim
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
      telescope-nvim
      telescope-media-files-nvim
      nvim-neoclip-lua
      FTerm-nvim
      tmux-nvim
      lualine-nvim
      nnn-vim
      nvim-surround
      comment-nvim
      nvim-cursorline
      flash-nvim
      nvim-ufo
      octo-nvim
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
      markdown-preview-nvim
      vim-markdown-toc
      go-nvim
      ChatGPT-nvim
    ];

    extraPackages = with pkgs; [
      # Telescope tools
      ripgrep
      fd

      # Debugger
      delve

      # Tools packages (Comes with a bunch of stuff)
      clang-tools
      gotools
      reftools
      ginkgo
      richgo
      gotestsum
      govulncheck
      mockgen

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

  sops.secrets.chatgpt_key.sopsFile = ./secrets.yaml;
}
