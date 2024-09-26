{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    {
      nixosConfigurations.use-module-filepath = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./base.nix
          ./configs/use-module-filepath.nix
        ];
      };
      nixosConfigurations.use-module-binding = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./base.nix
          ./configs/use-module-binding.nix
        ];
      };
      nixosConfigurations.use-module-binding-with-key = nixpkgs.lib.nixosSystem {
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ./base.nix
          ./configs/use-module-binding-with-key.nix
        ];
      };
    };
}
