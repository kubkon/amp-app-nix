{
  description = "Nix package for the Amp desktop app on Linux";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          amp-desktop = (pkgsFor system).callPackage ./package.nix { };
        in
        {
          inherit amp-desktop;
          default = amp-desktop;
        }
      );

      overlays.default = final: _prev: {
        amp-desktop = final.callPackage ./package.nix { };
      };

      formatter = forAllSystems (system: (pkgsFor system).nixfmt-tree);
    };
}
