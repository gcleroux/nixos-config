{ pkgs, config, ... }:
{

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
      require("themes.nordfox")

      -- Set up the UI
      require("ui")

      -- Debuggers config
      require("debuggers")

      -- Set up LSP (Should be loaded last)
      require("lsp")
    '';

    plugins = with pkgs.vimPlugins; [
      # LSP plugins
      go-nvim
      lsp-zero-nvim
      nvim-lint
      conform-nvim
      actions-preview-nvim
      nvim-lspconfig

      # CMP plugins
      cmp-buffer
      cmp-cmdline
      cmp-dap
      cmp-emoji
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      friendly-snippets
      luasnip
      nvim-cmp

      # Debugging plugins
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text

      # Utils plugins
      bufdelete-nvim
      SchemaStore-nvim
      comment-nvim
      flash-nvim
      neogen
      nvim-autopairs
      nvim-surround
      nvim-ufo
      nvim-web-devicons
      plenary-nvim
      popup-nvim
      rainbow-delimiters-nvim
      vim-suda
      tmux-nvim
      vim-markdown-toc

      # Themes plugins
      nightfox-nvim
      onenord-nvim

      # UI plugins
      toggleterm-nvim
      bufferline-nvim
      diffview-nvim
      gitsigns-nvim
      lualine-nvim
      markdown-preview-nvim
      octo-nvim
      trouble-nvim
      oil-nvim

      # Telescope plugins
      nvim-neoclip-lua
      telescope-media-files-nvim
      telescope-nvim
      fzf-lua

      # TreeSitter plugins
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
    ];

    extraPackages = with pkgs; [
      # Telescope tools
      ripgrep
      fd

      # Toggleterm tools
      bottom
      k9s
      lazygit

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
      bash-language-server
      dockerfile-language-server-nodejs
      nodePackages.typescript-language-server
      yaml-language-server
      python311Packages.jedi-language-server
      quick-lint-js
      taplo
      vscode-langservers-extracted

      # Linters
      actionlint
      buf
      codespell
      cppcheck
      dotenv-linter
      eslint_d
      golangci-lint
      hadolint
      luajitPackages.luacheck
      markdownlint-cli
      nodePackages.jsonlint
      proselint
      ruff
      shellcheck
      statix
      yamllint

      # Formatters
      cbfmt
      gofumpt
      isort
      nixfmt-rfc-style
      prettierd
      shfmt
      stylua
      golines
      goimports-reviser

      # Code actions
      gomodifytags
      gotests
      impl
      iferr
    ];
  };

  sops.secrets.chatgpt_api_key.sopsFile = ./secrets.yaml;
}
