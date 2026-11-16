{ config, pkgs, lib, ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    systemWide = true;
    alsa.enable = true;
    pulse.enable = true;
    # miniaudio's PulseAudio backend doesn't map PA_SAMPLE_S24_32LE (used by
    # 24-in-32-bit sinks like Amlogic/la-frite) and fails InitDevice with MA_ERROR.
    extraConfig.pipewire-pulse."15-force-s16-info" = {
      "pulse.rules" = [
        {
          matches = [
            { "application.process.binary" = "sendspin-go"; }
            { "application.process.binary" = ".sendspin-go-wrapped"; }
          ];
          actions = {
            quirks = [ "force-s16-info" ];
          };
        }
      ];
    };
  };

  users.users.ongy.extraGroups = [ "pipewire" ];

  environment.variables = {
    PIPEWIRE_RUNTIME_DIR = "/run/pipewire";
    PULSE_SERVER = "unix:/run/pulse/native";
  };

  environment.systemPackages = with pkgs; [
    sendspin-go
  ];

  networking.firewall.allowedUDPPorts = [
    5353
  ];

  systemd.services = {
    sendspin = {
      description = "Run the sendspin process";
      after = [
        "network-online.target"
        "sound.target"
        "pipewire.service"
        "pipewire-pulse.service"
        "wireplumber.service"
      ];
      wants = [
        "network-online.target"
        "pipewire.service"
        "pipewire-pulse.service"
        "wireplumber.service"
      ];
      serviceConfig = {
        ExecStart = "${pkgs.sendspin-go}/bin/sendspin-go -daemon";
        ExecStartPost = "${pkgs.bash}/bin/bash -c \"(journalctl -u %n -fn 0 | grep --line-buffered 'Burst sample 1/8 timed out' | while read -r _; do systemctl restart %n ; done) &\"";
        SupplementaryGroups = [ "pipewire" ];
      };
      wantedBy = [ "multi-user.target" ];
      environment = {
        PIPEWIRE_RUNTIME_DIR = "/run/pipewire";
        PULSE_SERVER = "unix:/run/pulse/native";
        LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.libpulseaudio ];
      };
    };
  };
}
