{ config, pkgs, lib, ... }:
{
	boot.kernelParams = lib.mkForce [ "console=ttyAML0,115200n8" "console=tty1" ];
	boot.initrd.kernelModules = [ "meson_drm" "meson_dw_hdmi" "display_connector" ];
	hardware.enableRedistributableFirmware = true;

	boot.loader.grub.enable = false;
	boot.loader.generic-extlinux-compatible.enable = true;

	fileSystems."/" = {
	  device = "/dev/disk/by-label/NIXOS_SD";
	  fsType = "ext4";
	};
}
