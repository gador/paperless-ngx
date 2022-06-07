
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
		 pypiDataRev = "ad7e4bc316ff4c8798728798274871c55a8def4d";
     pypiDataSha256 = "0a6a8iihl75xkrv2509anc3rfkrkq6s4rpm84qb9d1k3n29mpzmw";
  };
}
