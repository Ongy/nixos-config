{ config, pkgs, lib, ... }:

{
  services.openssh.enable = true;

  users = {
    users.ongy = {
      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6ukB8JFvR6FqcIl11dNne0o+jo0hglRrRQvrwmbebe ongy@ongy-nixos"];
    };
  };

  security.sudo.wheelNeedsPassword = false;
  # Servers mainly operate on root.
  # They only allow ssh on non-root, but most interaction is expected as root.
  environment.systemPackages = with pkgs; [ git ];
}
