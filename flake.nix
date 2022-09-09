{
  description = "closesource repo flake";

  # main
  inputs = {
    nixpkgs = {url = "github:nixos/nixpkgs/release-22.05";};
    deno2nix = {url = "github:SnO2WMaN/deno2nix/main";};
  };

  # dev
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    deno2nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          deno2nix.overlay
        ];
      };

      deno-api-dynamic-form = pkgs.deno2nix.mkExecutable {
        pname = "deno-api-dynamic-form";
        version = "0.0.0";

        src = ./.;
        lockfile = ./lock.json;

        output = "deno-api-dynamic-form";
        entrypoint = "./src/index.ts";
        importMap = "./import_map.json";
        additionalDenoFlags = "--allow-net --allow-env --allow-read";
      };
    in {
      # nix build .#<appName>
      packages = {
        inherit deno-api-dynamic-form;
      };
      apps.default = flake-utils.lib.mkApp {drv = self.packages.${system}.deno-api-dynamic-form;};
    });
}