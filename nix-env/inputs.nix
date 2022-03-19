
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
		 pypiDataRev = "a24485e8c1a8129cbda3b31c1eaa45a3207aa3db";
     pypiDataSha256 = "sha256:1brn900d1myrwahhjvrjdrfwzf9rc5r2rkbp499ab0axgp5ypf39";
  };
}
