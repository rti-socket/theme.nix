{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosModules.theme = import ./theme.nix;
      checks.${system}.theme =
        assert import ./tests/theme.nix { inherit (nixpkgs) lib; };
        pkgs.runCommand "theme-evaluation" { } ''
          touch $out
        '';
      packages.${system} = rec {
        gradient-png = import ./gradient-png.nix { inherit pkgs; };
      };
    };
}
