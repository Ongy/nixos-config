{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager.url = "github:nix-community/home-manager/release-26.05";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity-cli-nix = {
      url = "github:bigFin/antigravity-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, lanzaboote, antigravity-cli-nix }: {
    nixosConfigurations.ongy-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./common.nix
        nixos-hardware.nixosModules.framework-12-13th-gen-intel
 
        # Manage ongy user stuff
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit antigravity-cli-nix; };
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
        {
          networking = {
            hostName = "ongy-nixos";
          };
        }
      ];
    };
    nixosConfigurations.pi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./common.nix
        ./server.nix
        ./configuration-pi.nix
        ./sendspin.nix
        nixos-hardware.nixosModules.raspberry-pi-4

        {
          networking = {
            hostName = "pi";
          };
        }
      ];
    };
  };
}
