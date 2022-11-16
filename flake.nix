{
  inputs = {
    nixpkgs.url = "github:nix-ocaml/nix-overlays";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    let
      supported_ocaml_versions = [ "ocamlPackages_5_00" ];
      out = system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = nixpkgs.overlays."${system}".default;
            extraOverlays = [ (import ./nix/overlay.nix) ];
          };
          ocamlPackages_dev = pkgs.ocaml-ng.ocamlPackages_5_00;
          ocaml-http-server = (pkgs.callPackage ./nix {
            inherit nix-filter;
            doCheck = true;
            ocamlPackages = ocamlPackages_dev;
          });
        in {
          formatter = pkgs.callPackage ./nix/formatter.nix { };
          devShells = {
            default = (pkgs.mkShell {
              inputsFrom = [ ocaml-http-server ];

              buildInputs = with pkgs;
                with ocamlPackages_dev; [
                  ocaml-lsp
                  ocamlformat_0_20_1
                  odoc
                  ocaml
                  dune_3
                  nixfmt
                  treefmt
                ];
              packages = with pkgs; [ wrk ];
            });
          };

          packages = builtins.foldl' (prev: ocamlVersion:
            prev // {
              "ocaml-http-server_${ocamlVersion}" = ocaml-http-server.override {
                ocamlPackages = pkgs.ocaml-ng."${ocamlVersion}";
              };
            }) {
              # ocaml 5.00 version is available as default, ocaml-http-server 
              inherit ocaml-http-server;
              default = ocaml-http-server;
            } supported_ocaml_versions;
        };
    in with flake-utils.lib;
    eachSystem [
      system.x86_64-linux
      system.aarch64-linux
      system.x86_64-darwin
      system.aarch64-darwin
    ] out // {
      overlays.default =
        import ./nix/overlay.nix supported_ocaml_versions nix-filter;
      hydraJobs = {
        x86_64-linux.default = self.packages.x86_64-linux;
        aarch64-darwin.default = self.packages.aarch64-darwin;
      };
    };

}
