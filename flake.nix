{
  description = "closesource repo flake";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/release-22.05"; };

    deno2nix = { url = "github:SnO2WMaN/deno2nix/main"; };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
  };

  outputs = { self, nixpkgs, flake-utils, deno2nix, ... }:
      flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
          overlays = [
            deno2nix.overlay
          ];
        });

          deno-api-dynamic-form = pkgs.deno2nix.mkExecutable {
            name = "deno-api-dynamic-form";
            version = "0.0.0";
            src = ./.;
            denoFlags = ["--allow-net" "--allow-env" "--allow-read" "--import-map=./import_map.json"];
            lockfile = ./lock.json;
            entrypoint = ./index.ts;
          };
      in {
        # nix build .#<appName>
        packages = {
          inherit deno-api-dynamic-form;
        };
      });
}
