final: prev:
let
  disableCheck = package: package.overrideAttrs (o: { doCheck = false; });
  addCheckInputs = package:
    package.overrideAttrs ({ buildInputs ? [ ], checkInputs, ... }: {
      buildInputs = buildInputs ++ checkInputs;
    });
in {
  ocaml-ng = builtins.mapAttrs (_: ocamlVersion:
    ocamlVersion.overrideScope' (oself: osuper: {
      piaf = osuper.piaf.overrideAttrs (o: {
        src = prev.fetchFromGitHub {
          owner = "anmonteiro";
          repo = "piaf";
          rev = "f973028df3c71ceea345d8116d7c5d200a680e52";
          sha256 = "sha256-n11OP/RHXgr3GshN73f322g1n8MnHOL7S6ZSeIeZf6k=";
          fetchSubmodules = true;
        };
        patches = [ ];
        doCheck = false;
        propagatedBuildInputs = with osuper; [
          websocketaf
          eio
          eio_main
          eio-ssl
          httpaf-eio
          h2-eio
          ipaddr
          magic-mime
          multipart_form
          sendfile
          uri
        ];
      });
    })) prev.ocaml-ng;
}
