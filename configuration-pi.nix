{ config, pkgs, lib, ... }:

{
  boot = {
    kernelParams = [ "snd_bcm2835.enable_hdmi=1" "snd_bcm2835.enable_headphones=0" ];
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  hardware.alsa.enable = true;

  environment.systemPackages = with pkgs; [
    (callPackage ./sendspin-go.nix {})
    alsa-lib
  ];

  networking.firewall.extraInputRules = [
    "tcp dport 8927 accept"
    "tcp dport 8928 accept"
    "udp dport 5353 accept"
    "udp sport 5353 accept"
  ];

  hardware.enableRedistributableFirmware = true;
}
