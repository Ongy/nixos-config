{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    (callPackage ./sendspin-go.nix {})
    alsa-lib
  ];

  networking.firewall.allowedUDPPorts = [
    5353
  ];

  systemd.services = {
    sendspin = {
        description = "Run the sendspin process";
        serviceConfig = {
          ExecStart = "/run/current-system/sw/bin/sendspin-go -daemon -audio-device 'Default Audio Device'";
          ExecStartPost="${pkgs.bash}/bin/bash -c \"(journalctl -u %n -fn 0 | grep --line-buffered 'Burst sample 1/8 timed out' | while read -r _; do systemctl restart %n ; done) &\"";
        };
        wantedBy = ["multi-user.target"];
        environment = {
          LD_LIBRARY_PATH="${pkgs.alsa-lib}/lib";
        };
    };
  };
}
