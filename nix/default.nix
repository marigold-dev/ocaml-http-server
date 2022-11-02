
{ pkgs, stdenv, lib, nix-filter, ocamlPackages, doCheck }:

with ocamlPackages;
buildDunePackage {
  pname = "ocaml-http-server";
  version = "0.1.0";

  # Using nix-filter means we only rebuild when we have to
  src = with nix-filter.lib;
    filter {
      root = ../.;
      include = [
        "dune-project"
        "ocaml_http_server.opam"
        "README.md"
        (inDirectory "lib")
        (inDirectory "test")
      ];
    };

  # checkInputs = [ alcotest alcotest-lwt ];

  propagatedBuildInputs = [
    piaf
    routes
  ];

  inherit doCheck;

  meta = {
    description =
      "A platform agnostic library for P2P communications using UDP and Bin_prot";
  };
}