# shell.nix
{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    python39
    pipenv
    zbar
    poppler_utils
    imagemagick
  ];
  shellHook = ''
    export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.zlib}/lib:${pkgs.imagemagick}/lib:$LD_LIBRARY_PATH
  '';
}
