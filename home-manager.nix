{ config, pkgs, lib, ... }:
let
  home-manager = (builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
    sha256 = "0q3lv288xlzxczh6lc5lcw0zj9qskvjw3pzsrgvdh8rl8ibyq75s";
  });
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  #tarball-ttl = 86400;
  home-manager.users.ongy = {
    nixpkgs.config.allowUnfree = true;
    home.stateVersion="25.05";
    home.packages = with pkgs; [
      (writeShellScriptBin "alacritty-session" "systemd-run --user alacritty")
      swaybg
      mosh

      grim
      slurp
      mako
      alacritty
      pavucontrol
  
      tor-browser-bundle-bin
      firefox
      chromium
      qutebrowser

      libreoffice
  
      bitwarden

      kubectl
      k9s

      buildah

      (import ./notifiers.nix)
    ];

    wayland.systemd.target = "sway-session.target";
    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      config = rec {
         modifier = "Mod4";
         terminal = "alacritty-session";
         assigns = {
           "1: qutebrowser" = [{app_id = "org.qutebrowser.qutebrowser";}];
           "3: chromium" = [{app_id = "chromium-browser";}];
           "4: firefox" = [{app_id = "firefox";}];
         };
         menu = "${pkgs.dmenu}/bin/dmenu_path | ${pkgs.dmenu}/bin/dmenu | ${pkgs.findutils}/bin/xargs systemd-run --user --";
         keybindings = let
           modifier = config.wayland.windowManager.sway.config.modifier;
         in lib.mkOptionDefault {
           "XF86MonBrightnessUp"   = "exec brightnessctl set 5%+";
           "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
           
           "XF86AudioRaiseVolume"  = "exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+'";
           "XF86AudioLowerVolume"  = "exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'";
           "XF86AudioMute"         = "exec 'wpctl set-mute @DEFAULT_SINK@ toggle'";

         };
         keycodebindings = let
           modifier = config.wayland.windowManager.sway.config.modifier;
         in lib.mkOptionDefault {
         };

         input."type:keyboard" = {
           xkb_layout = "us";
           xkb_variant = "altgr-intl";
           xkb_options = "caps:ctrl_modifier";
         };
      };
    };

    programs.git = {
      enable = true;
      userName = "Markus Ongyerth";
      userEmail = "ongyerth@google.com";
      extraConfig = {
        safe.directory = "/etc/nixos";
      };
    };
  
    programs.zsh = {
      enable = true;
    };
    programs.swaylock.enable = true;

    systemd.user.services = {
      swaybg = {
        Unit = {
          Description = "Background image";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "/home/ongy/.nix-profile/bin/swaybg --mode fit --image \${HOME}/background.png"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      volume-notifier = {
        Unit = {
          Description = "Volume change notification daemone";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "/home/ongy/.nix-profile/bin/audio-notifier"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      brightness-notifier = {
        Unit = {
          Description = "Brightness notifier";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "/home/ongy/.nix-profile/bin/brightness-notifier"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      qutebrowser = {
        Unit = {
          Description = "Primary browser instance";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "/home/ongy/.nix-profile/bin/qutebrowser"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      firefox-session = {
        Unit = {
          Description = "Firefox browser instance";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "/home/ongy/.nix-profile/bin/firefox"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      chromiume = {
        Unit = {
          Description = "Chromium browser instance";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "/home/ongy/.nix-profile/bin/chromium-browser"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
    };

    programs.vscode = {
      enable = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        vscodevim.vim
        yzhang.markdown-all-in-one
      ];
    };
  };
}
