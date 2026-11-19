{
  description = "NixOS + home-manager config: dwl, fuzzel, foot in gruvbox";

  inputs = {
    # include git submodules (modules/rice/dwl) in the flake source
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # named after networking.hostName, so `nixos-rebuild --flake .` picks it
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };

      # `nix develop` (or direnv): tools used by .githooks/pre-commit
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          shfmt
          shellcheck
          nixfmt
        ];
        shellHook = ''
          git config core.hooksPath .githooks
        '';
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
