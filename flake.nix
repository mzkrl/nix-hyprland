{
  description = "NixOS Configuration with Caelestia Shell and Home Manager";

  inputs = {
    # Stable NixOS release — predictable updates, less rebuild churn.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    caelestia-shell.url = "github:caelestia-dots/shell";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };

      modules = [
        ./nixos/configuration.nix

        home-manager.nixosModules.home-manager

        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.juang = import ./home/default.nix;
        }
      ];
    };
  };
}