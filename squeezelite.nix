{ config, pkgs, lib, ... }:

{
  services.squeezelite.enable = true;

  networking.firewall.extraInputRules = [
    "udp sport 3483 accept"
  ];
}
