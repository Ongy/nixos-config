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
        serviceConfig = { ExecStart = "/run/current-system/sw/bin/sendspin-go -daemon -audio-device 'Default Audio Device'"; };
        wantedBy = ["multi-user.target"];
        environment = {
          LD_LIBRARY_PATH="${pkgs.alsa-lib}/lib";
        };
    };
  };
}
