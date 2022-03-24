with (import ./inputs.nix);
let
  reqFile = ../requirements.txt;
  fixedReqFile = builtins.readFile (pkgs.runCommand "fixReqFile"
    {
      buildInputs = [ ];
    }
    ''
      		# comment the index urls at the top of the file, since mach-nix can't handle them
      		# version of cryptography is too recent
      		# nixpkgs is needed for setuptools and still behind the current version
      		substitute ${reqFile} $out \
      			--replace "-i https://pypi.python.org/simple" "" \
      			--replace "--extra-index-url https://www.piwheels.org/simple" "" \
      			--replace "cryptography==36.0.1" "cryptography>=36" \
      			--replace "setuptools==60.9.3" "setuptools>=57" \
      			--replace "python-magic==0.4.25" "python-magic" \
      			--replace "ocrmypdf==13.4.0" "ocrmypdf>=13.4"
      		echo "pytest" >> $out
      		echo "pytest-cov" >> $out
          echo "pytest-django" >> $out
          echo "pytest-env" >> $out
          echo "pytest-sugar" >> $out
          echo "pytest-xdist" >> $out
          echo "factory_boy" >> $out
          echo "black" >> $out
    '');
in
mach-nix.mkPython {
  requirements = fixedReqFile;
  providers.pyzbar = "nixpkgs";
  providers.python-magic = "nixpkgs";
  providers.ocrmypdf = "nixpkgs";
  #packagesExtra = [
  #   "https://github.com/NaturalHistoryMuseum/pyzbar/archive/refs/tags/v0.1.9.tar.gz"
  #];
  # #providers.pyzbar = "sdist"
  # _.pyzbar.buildInputs.add = [ pkgs.zbar ];
}
