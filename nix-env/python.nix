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
      		# relax version constrains, so they work with nixpkgs
					# which is sometimes necessary for dependencies to work
      		substitute ${reqFile} $out \
      			--replace "-i https://pypi.python.org/simple/" "" \
      			--replace "--extra-index-url https://www.piwheels.org/simple/" "" \
      			--replace "cryptography==36.0.1" "cryptography>=36" \
      			--replace "setuptools==60.9.3" "setuptools>=57" \
      			--replace "python-magic==0.4.25" "python-magic" \
      			--replace "ocrmypdf==13.4.1" "ocrmypdf>=13.4"
					# add packages required by pytest
					echo "pytest" >> $out
      		echo "pytest-cov" >> $out
          echo "pytest-django" >> $out
          echo "pytest-env" >> $out
          echo "pytest-sugar" >> $out
          echo "pytest-xdist" >> $out
          echo "factory_boy" >> $out
          # add additional useful python packages to the shell
					echo "black" >> $out
					echo "reorder-python-imports" >> $out
          echo "add-trailing-comma" >> $out
          echo "flake8" >> $out
    '');
in
mach-nix.mkPython {
  requirements = fixedReqFile;
  providers.pyzbar = "nixpkgs";
  providers.python-magic = "nixpkgs";
  providers.ocrmypdf = "nixpkgs";
}
