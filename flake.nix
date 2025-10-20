{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager/release-25.05";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";

      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, lanzaboote }: {
    nixosConfigurations.ongy-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.framework-12-13th-gen-intel
 
        # Manage ongy user stuff
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ongy = ./home-manager.nix;
        }

        # Secure boot related tooling
        lanzaboote.nixosModules.lanzaboote
        ({ pkgs, lib, ... }: {

          environment.systemPackages = [
            # For debugging and troubleshooting Secure Boot.
            pkgs.sbctl
          ];

          # Lanzaboote currently replaces the systemd-boot module.
          # This setting is usually set to true in configuration.nix
          # generated at installation time. So we force it to false
          # for now.
          boot.loader.systemd-boot.enable = lib.mkForce false;

          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";
          };
        })
      ];
    };
    nixosConfigurations.pi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration-pi.nix
        ./common.nix
        ./server.nix
        ./squeezelite.nix

        {
          networking = {
            hostName = "pi";
          };
          services.squeezelite.extraArguments = "-m dc:a6:32:c1:86:62";
        }
      ];
    };
  };
}
