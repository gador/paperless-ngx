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
            			--replace "-i https://pypi.python.org/simple" "" \
            			--replace "--extra-index-url https://www.piwheels.org/simple" "" \
            			--replace "cryptography==37.0.1" "cryptography>=36" \
            			--replace "setuptools==62.1.0" "setuptools>=57" \
            			--replace "python-magic==0.4.25" "python-magic" \
            			--replace "ocrmypdf==13.4.3" "ocrmypdf>=13.4" \
                  --replace "pdfminer.six==20220319" "pdfminer.six" \
                  --replace "img2pdf==0.4.4" "img2pdf>=0.4.3" \
                  --replace "pillow==9.1.0" "pillow>=9.0" \
                  --replace "django==4.0.4" "django>=4.0" \
                  --replace "twisted[tls]==22.4.0" "twisted[tls]>=22.0" \
                  --replace "pikepdf==5.1.2" "pikepdf>=5.0" \
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
                echo "pycodestyle" >> $out
                echo "sphinx" >> $out
                echo "sphinx_rtd_theme" >> $out
    '');
in
mach-nix.mkPython {
  requirements = fixedReqFile;
  providers.pyzbar = "nixpkgs";
  providers.python-magic = "nixpkgs";
  providers.ocrmypdf = "nixpkgs";
  providers.pillow = "nixpkgs";
  providers.pikepdf = "nixpkgs";
  providers.img2pdf = "nixpkgs";
  _.pikepdf.buildInputs.add = [ pkgs.python3Packages.pybind11 ];
  _.numpy.buildInputs.add = [ pkgs.zlib ];
}
