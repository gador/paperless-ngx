
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
		 pypiDataRev = "fada47f634f574cb19ffd850f398542d54a97cae";
     pypiDataSha256 = "0pldxnc91jz49vx2kddfd1h4fir1jwk2vrdax2z1fzpvxvzpnizs";
  };
}
