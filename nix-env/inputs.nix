
with builtins;
let
  lock = fromTOML (readFile ./lock.toml);
in rec {
  pkgs = import (builtins.fetchTarball {
    name = "nixpkgs";
    url = "https://github.com/nixos/nixpkgs/tarball/${lock.nixpkgs.rev}";
    sha256 = "${lock.nixpkgs.sha256}";
  }) { config = {}; overlays = []; };
  mach-nix = import (builtins.fetchTarball {
    url = "https://github.com/DavHau/mach-nix/tarball/${lock.mach-nix.rev}";
    sha256 = lock.mach-nix.sha256;
  }) {
    python = "python39";
    inherit pkgs;
		 pypiDataRev = "9cbdfbb16a252f81d9754877d65010f214f110e3";
     pypiDataSha256 = "sha256:0x345p1hj96l0wn8xlp6vbzckmp8l0m03hjfcwsxmg3c43g8xclk";
  };
}
