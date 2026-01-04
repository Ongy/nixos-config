{ config, pkgs, lib, ... }:
let
  desktop-notifiers = (pkgs.callPackage ./notifiers.nix {});
in
{
    home.stateVersion="25.05";
    home.packages = with pkgs; [
      (writeShellScriptBin "screenshot" "grim -g \"$(slurp -d)\"")
      (writeShellScriptBin "alacritty-session" "systemd-run --user alacritty")
      (writeShellScriptBin "screen-rotator" ''
/run/current-system/sw/bin/monitor-sensor --accel |  while read line; do echo
  case ''$(echo "''${line}" | /run/current-system/sw/bin/cut -d ':' -f 2 | /run/current-system/sw/bin/tr -d ' ') in
    normal)
      ${pkgs.sway}/bin/swaymsg output eDP-1 transform 0 ;;
    right-up)
      ${pkgs.sway}/bin/swaymsg output eDP-1 transform 90 ;;
    bottom-up)
      ${pkgs.sway}/bin/swaymsg output eDP-1 transform 180 ;;
    left-up)
      ${pkgs.sway}/bin/swaymsg output eDP-1 transform 270 ;;
  esac
done
'')
      swaybg
      mosh
      squeekboard
      xss-lock

      grim
      slurp
      mako
      alacritty
      pavucontrol
  
      tor-browser-bundle-bin
      firefox
      chromium
      qutebrowser
      google-chrome

      anki
      libreoffice
  
      bitwarden

      kubectl
      k9s

      buildah

      desktop-notifiers   
    ];
    home.sessionVariables = {
      QT_QPA_PLATFORM="wayland";
      QT_IM_MODULE="fcitx";
      GTK_IM_MODULE="fcitx";
    };

    wayland.systemd.target = "sway-session.target";
    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      systemd.variables = [
        "DISPLAY"
        "WAYLAND_DISPLAY"
        "SWAYSOCK"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
        "NIXOS_OZONE_WL"
        "XCURSOR_THEME"
        "XCURSOR_SIZE"

        "QT_QPA_PLATFORM"
        "QT_IM_MODULE"
        "GTK_IM_MODULE"
      ];
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
           modifier = "Mod4";
         in lib.mkOptionDefault {
           "XF86MonBrightnessUp"   = "exec brightnessctl set 5%+";
           "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
           
           "XF86AudioRaiseVolume"  = "exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+'";
           "XF86AudioLowerVolume"  = "exec 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'";
           "XF86AudioMute"         = "exec 'wpctl set-mute @DEFAULT_SINK@ toggle'";

           "Print"                 = "exec /etc/profiles/per-user/ongy/bin/screenshot";

           "${modifier}+greater"     = "move workspace to output right";
           "${modifier}+less"        = "move workspace to output left";
           "${modifier}+x"           = "exec ${pkgs.swaylock}/bin/swaylock --color 001100 --show-failed-attempts --image /home/ongy/background.png --scaling center";
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
        push.autoSetupRemote = "true";
        push.default = "upstream";
      };
    };
  
    programs.zsh = {
      enable = true;
    };
    programs.swaylock.enable = true;
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [];
    };

    systemd.user.services = {
      swaybg = {
        Unit = {
          Description = "Background image";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "${pkgs.swaybg}/bin/swaybg --mode fit --image \${HOME}/background.png"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      volume-notifier = {
        Unit = {
          Description = "Volume change notification daemone";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "${desktop-notifiers}/bin/audio-notifier"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      brightness-notifier = {
        Unit = {
          Description = "Brightness notifier";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "${desktop-notifiers}/bin/brightness-notifier"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      qutebrowser = {
        Unit = {
          Description = "Primary browser instance";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "${pkgs.qutebrowser}/bin/qutebrowser"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      firefox-session = {
        Unit = {
          Description = "Firefox browser instance";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "${pkgs.firefox}/bin/firefox"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      chromium = {
        Unit = {
          Description = "Chromium browser instance";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "${pkgs.chromium}/bin/chromium-browser"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      screen-rotator = {
        Unit = {
          Description = "Utility to trigger screen rotation on physical rotation";
          After = ["graphical-session.target"];
        };
        Service = { ExecStart = "/etc/profiles/per-user/ongy/bin/screen-rotator"; };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      swaylock = {
        Unit = {
          Description = "Lock the screen";
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.xss-lock}/bin/xss-lock -- ${pkgs.swaylock}/bin/swaylock --color 001100 --show-failed-attempts --image \${HOME}/background.png --scaling center";
        };
        Install = { WantedBy = ["sway-session.target"]; };
      };
      fcitx5 = {
        Unit = {
          Description = "Provide the input method";
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "/run/current-system/sw/bin/fcitx5";
        };
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
}
