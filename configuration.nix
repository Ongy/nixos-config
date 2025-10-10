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
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;
  boot.bootspec.enable = true;
  boot.initrd.systemd.enable = true;

  networking.hostName = "ongy-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # Configure console keymap
  console.keyMap = "us-acentos";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ongy = {
    isNormalUser = true;
    description = "Markus Ongyerth";
    extraGroups = [ "networkmanager" "wheel" "tss" ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    tarball-ttl = 604800
'';
  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    jq

    python3

    mtr
    htop
    framework-tool

    libinput
    sway

    steam
    steam-run
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };
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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

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

}
