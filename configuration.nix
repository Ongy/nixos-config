# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, options, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot = {
    tmp.useTmpfs = true;
    bootspec.enable = true;
    initrd.systemd.enable = true;

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader = {
      timeout = 0;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = true;
  users.users.ongy = {
    extraGroups = [ "networkmanager" "tss" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    python3
    framework-tool

    libinput
    sway

    steam
    steam-run
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };
  security.polkit.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  fileSystems."/media/home" = {
    device = "//mario.local.ongy.net/shared";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,uid=1000,gid=1000";

    in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.xserver.enable = true;
  services.displayManager.enable = true;
  services.displayManager.autoLogin = {
    enable = false;
    user = "ongy";
  };
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      epson-escpr
    ];
  };

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';
#   services.logind.settings.Login = {
#     HandlePowerKey="suspend";
#   };

  # required for buildah...
  environment.etc."containers/policy.json" = {
    text = "{\"default\": [{\"type\": \"insecureAcceptAnything\"}]}";
    mode = "0444";
  };
#   environment.etc."systemd/system-sleep/mute.sh" = {
#     mode = "0755";
#     text = ''
#       #! ${pkgs.runtimeShell}
# 
#       case "''${1}" in
#         pre)
#           ${pkgs.sudo}/bin/sudo -u ongy ${pkgs.coreutils-full}/bin/env XDG_RUNTIME_DIR=/run/user/1000 $HOME=/home/ongy ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_SINK@ 1
#         ;;
#       esac
# '';
#   };

  # This is required for steam
  hardware.graphics.enable32Bit = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      libsForQt5.fcitx5-qt
      kdePackages.fcitx5-qt
      fcitx5-mozc
    ];
  };

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;  # expose /run/current-system/sw/lib/libtpm2_pkcs11.so
    tctiEnvironment.enable = true;  # TPM2TOOLS_TCTI and TPM2_PKCS11_TCTI env variables
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "EPSON_XP-7100_Series";
        location = "Home";
        deviceUri = "lpd://192.168.3.200:515/PASSTHRU";
        model = "epson-inkjet-printer-escpr/Epson-XP-7100_Series-epson-escpr-en.ppd";
      }
    ];
    ensureDefaultPrinter = "EPSON_XP-7100_Series";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Mess with CPU allocations for prioritizing sway
  systemd.units = {
    # this makes sure all system level systemd services do not run on CPU 11
    "service" = {
      overrideStrategy = "asDropin";
      text  = ''
      [Service]
      AllowedCPUs=
      AllowedCPUs=0-10
      '';
    };
    # This homes all user level systemd services and makes sure they are not on CPU 11
    "user@1000.service" = {
      overrideStrategy = "asDropin";
      text  = ''
      [Service]
      AllowedCPUs=
      AllowedCPUs=0-10
      '';
    };
    # session-2.scope is the standard scope fo the user session with lightdm in this config.
    # I'm not quite sure where it's generated, so for now it's just a match by name.
    # It does contain sway, and things directly launched by sway.
    # but since my setup isolates every task from sway via systemd-user (See home-manager config)
    # everything else will run under user@1000.service
    "session-2.scope" = {
      overrideStrategy = "asDropin";
      text  = ''
      [Scope]
      AllowedCPUs=
      AllowedCPUs=11
      '';
    };
  };
}
