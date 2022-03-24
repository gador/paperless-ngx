{ pkgs ? import /home/florian/software/git/nixpkgs { } }:
pkgs.callPackage ./derivation.nix { }
