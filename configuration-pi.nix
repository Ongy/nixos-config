{ config, pkgs, lib, ... }:

{
  boot = {
    kernelParams = [ "snd_bcm2835.enable_hdmi=1" "snd_bcm2835.enable_headphones=0" ];
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    extraModprobeConfig = ''
      options vc4 enable_v3d=0
    '';
    blacklistedKernelModules = [
      "v3d"
    ];
  };

  hardware.raspberry-pi.firmware = {
    enable = true;
    uboot.enable = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  hardware.alsa.enable = true;

  hardware.enableRedistributableFirmware = true;
}
