{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});
      treefmtEval = forAllSystems (
        pkgs:
        treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.mdformat.enable = true;
          programs.nixfmt.enable = true;
        }
      );
    in
    {
      formatter = forAllSystems (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            treefmtEval.${pkgs.system}.config.build.wrapper
          ];
        };
      });
    };
}
