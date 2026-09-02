{
  description = "Native Nix package for Web App Hub";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          webAppHub = pkgs.callPackage ./nix/package.nix { };
        in
        {
          default = webAppHub;
          web-app-hub = webAppHub;
        });

      apps = forAllSystems (system:
        let
          program = "${self.packages.${system}.web-app-hub}/bin/web-app-hub";
        in
        {
          default = { type = "app"; inherit program; };
          web-app-hub = { type = "app"; inherit program; };
        });

      overlays.default = final: _prev: {
        web-app-hub = final.callPackage ./nix/package.nix { };
      };

      nixosModules = rec {
        default = web-app-hub;
        web-app-hub = { config, lib, pkgs, ... }:
          import ./nix/module.nix {
            inherit config lib pkgs;
            defaultPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.web-app-hub;
          };
      };

      homeManagerModules = rec {
        default = web-app-hub;
        web-app-hub = { config, lib, pkgs, ... }:
          import ./nix/home-manager-module.nix {
            inherit config lib pkgs;
            defaultPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.web-app-hub;
          };
      };

      checks = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          package = self.packages.${system}.web-app-hub;
        in
        {
          inherit package;
          install-layout = pkgs.runCommand "web-app-hub-install-layout" {
            nativeBuildInputs = [ pkgs.desktop-file-utils ];
          } ''
            test -x ${package}/bin/web-app-hub
            test -f ${package}/share/applications/org.pvermeer.WebAppHub.desktop
            test -f ${package}/share/icons/hicolor/256x256/apps/org.pvermeer.WebAppHub.png
            test -f ${package}/share/metainfo/org.pvermeer.WebAppHub.metainfo.xml
            desktop-file-validate ${package}/share/applications/org.pvermeer.WebAppHub.desktop
            touch $out
          '';
        });

      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.web-app-hub ];
            packages = with pkgs; [ cargo rustc rustfmt clippy ];
          };
        });
    };
}
