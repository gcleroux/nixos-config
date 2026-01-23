{ config, pkgs, ... }:
{
  programs.aerc = {
    enable = true;
    extraBinds = {
      global = {
        "<C-h>" = ":prev-tab<Enter>";
        "<C-l>" = ":next-tab<Enter>";
        "?" = ":help keys<Enter>";
      };

      messages = {
        # Navigation
        "h" = ":prev-tab<Enter>";
        "l" = ":next-tab<Enter>";
        "j" = ":next<Enter>";
        "k" = ":prev<Enter>";

        # Folder navigation
        "J" = ":next-folder<Enter>";
        "<C-j>" = ":next-folder<Enter>";
        "K" = ":prev-folder<Enter>";
        "<C-k>" = ":prev-folder<Enter>";
        "H" = ":collapse-folder<Enter>";
        "L" = ":expand-folder<Enter>";
        "F" = ":cf<space>"; # Search folder

        # Vim-like scrolling
        "<C-u>" = ":prev 50%<Enter>";
        "<C-b>" = ":prev 100%<Enter>";
        "<C-d>" = ":next 50%<Enter>";
        "<C-f>" = ":next 100%<Enter>";
        "g" = ":select 0<Enter>";
        "G" = ":select -1<Enter>";

        # Select messages
        "<Enter>" = ":view<Enter>";
        "<space>" = ":mark -t<Enter>";
        "V" = ":mark -v<Enter>";

        # Mail command
        "c" = ":compose<Enter>"; # New
        "C" = ":check-mail<Enter>"; # Sync
        "u" = ":unread -t<Enter>"; # Toggle read/unread
        "t" = ":tag<space>"; # Tag +/- to add/remove
        "T" = ":toggle-threads<Enter>";

        # Delete/archive
        "d" = ":prompt 'Really delete this message?' 'delete-message'<Enter>";
        "D" = ":delete<Enter>";
        "A" = ":archive flat<Enter>";

        # Reply/Reply-all
        "rr" = ":reply<Enter>";
        "ra" = ":reply -a<Enter>";

        # Reply/Reply-all with quoted message
        "Rr" = ":reply -q<Enter>";
        "Ra" = ":reply -aq<Enter>";

        # Search/filter
        "/" = ":search<space>";
        "\\" = ":filter<space>";
        "n" = ":next-result<Enter>";
        "N" = ":prev-result<Enter>";
        "<Esc>" = ":clear<Enter>";

        "$" = ":term<space>";
        "!" = ":term<space>";
        "|" = ":pipe<space>";
      };

      "messages:folder=Drafts" = {
        "<Enter>" = ":recall<Enter>";
      };

      view = {
        "/" = ":toggle-key-passthrough<Enter>/";
        "q" = ":close<Enter>";
        "O" = ":open<Enter>";
        "S" = ":save<space>";
        "|" = ":pipe<space>";
        "D" = ":delete<Enter>";
        "A" = ":archive flat<Enter>";

        "<L>" = ":open-link <space>";

        "f" = ":forward<Enter>";
        "rr" = ":reply -a<Enter>";
        "rq" = ":reply -aq<Enter>";
        "Rr" = ":reply<Enter>";
        "Rq" = ":reply -q<Enter>";

        "H" = ":toggle-headers<Enter>";
        "<C-k>" = ":prev-part<Enter>";
        "<C-j>" = ":next-part<Enter>";
        "J" = ":next<Enter>";
        "K" = ":prev<Enter>";
      };

      "view::passthrough" = {
        "$noinherit" = true;
        "$ex" = "<C-x>";
        "<Esc>" = ":toggle-key-passthrough<Enter>";
      };

      compose = {
        "$noinherit" = "true";
        "$ex" = "<C-x>";
        "<C-k>" = ":prev-field<Enter>";
        "<C-j>" = ":next-field<Enter>";
        "<A-p>" = ":switch-account -p<Enter>";
        "<A-n>" = ":switch-account -n<Enter>";
        "<tab>" = ":next-field<Enter>";
        "<C-h>" = ":prev-tab<Enter>";
        "<C-l>" = ":next-tab<Enter>";
      };

      "compose::editor" = {
        "$noinherit" = "true";
        "$ex" = "<C-x>";
        "<C-k>" = ":prev-field<Enter>";
        "<C-j>" = ":next-field<Enter>";
        "<C-h>" = ":prev-tab<Enter>";
        "<C-l>" = ":next-tab<Enter>";
      };

      "compose::review" = {
        "y" = ":send<Enter>";
        "n" = ":abort<Enter>";
        "p" = ":postpone<Enter>";
        "q" = ":choose -o d discard abort -o p postpone postpone<Enter>";
        "e" = ":edit<Enter>";
        "a" = ":attach<space>";
        "d" = ":detach<space>";
      };

      terminal = {
        "$noinherit" = "true";
        "$ex" = "<C-x>";

        "<C-h>" = ":prev-tab<Enter>";
        "<C-l>" = ":next-tab<Enter>";
      };
    };

    extraConfig = {
      general.unsafe-accounts-conf = true;
      ui = {
        this-day-time-format = ''"           15:04"'';
        this-year-time-format = "Mon Jan 02 15:04";
        timestamp-format = "2006-01-02 15:04";
        spinner = "[ ⡿ ],[ ⣟ ],[ ⣯ ],[ ⣷ ],[ ⣾ ],[ ⣽ ],[ ⣻ ],[ ⢿ ]";
      };
      triggers = {
        new-email = ''exec notify-send "New email from %n" "%s"'';
      };
      filters = {
        "text/plain" = "colorize";
        "text/html" = "html";
        "text/calendar" = "calendar";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
        "image/*" = "${pkgs.catimg}/bin/catimg -";
      };
    };
  };
  accounts.email.accounts = {
    Personal = {
      primary = true;
      aerc = {
        enable = true;
        extraAccounts = {
          folders-sort = "INBOX,Drafts,Sent,Archive,Trash,Junk";
        };
      };
      realName = "Guillaume Cléroux";
      address = "guillaume@cleroux.dev";
      imap.host = "imap.migadu.com";
      smtp.host = "smtp.migadu.com";

      userName = "guillaume@cleroux.dev";
      passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.migadu_password.path}";
    };
    Pinax = {
      aerc.enable = true;
      address = "guillaume@eosnation.io";
      realName = "Guillaume Cléroux";
      imap.host = "imap.gmail.com";
      smtp.host = "smtp.gmail.com";

      userName = "guillaume@eosnation.io";
      passwordCommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.gmail_password.path}";
    };
  };

  sops.secrets.migadu_password = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
  };
  sops.secrets.gmail_password = {
    sopsFile = ./secrets.yaml;
    format = "yaml";
  };
}
