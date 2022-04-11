
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
		 pypiDataRev = "c62c16dea41a1e8169826ac73d1522f3233d92a5";
     pypiDataSha256 = "1igf4iw06fcnrcj1p2zvk2wh9b49df650i8akzj5549ydf8gdzaz";
  };
}
