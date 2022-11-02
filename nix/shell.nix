{
  pkgs,
}:
with pkgs;
with ocamlPackages;
  mkShell {
    packages = [
        # Formatters
        nixfmt
        ocamlformat

        # OCaml developer tooling
        ocaml
        dune_3
        ocaml-lsp
        ocamlformat-rpc
        utop
        
        routes
        piaf
    ];
  }
