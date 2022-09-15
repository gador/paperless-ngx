with (import ./inputs.nix);
let
  reqFile = ../requirements.txt;
  fixedReqFile = builtins.readFile (pkgs.runCommand "fixReqFile"
    {
      buildInputs = [ ];
    }
    ''
            		# comment the index urls at the top of the file, since mach-nix can't handle them
            		# relax version constrains, so they work with nixpkgs
      					# which is sometimes necessary for dependencies to work
								# add django-q, since mach-nix cannot build the provided package, as it uses poetry
            		substitute ${reqFile} $out \
            			--replace "-i https://pypi.python.org/simple" "" \
            			--replace "--extra-index-url https://www.piwheels.org/simple" "" \
            			--replace "cryptography==37.0.4" "cryptography>=37" \
            			--replace "setuptools==63.1.0" "setuptools>=61" \
            			--replace "python-magic==0.4.25" "python-magic>=0.4" \
            			--replace "ocrmypdf==13.4.4" "ocrmypdf>=13.4" \
                  --replace "pdfminer.six==20220319" "pdfminer.six" \
                  --replace "img2pdf==0.4.4" "img2pdf>=0.4.3" \
                  --replace "pillow==9.2.0" "pillow>=9.1" \
                  --replace "twisted[tls]==22.4.0" "twisted[tls]>=22.0" \
                  --replace "pikepdf==5.3.1" "pikepdf>=5.0" \
                  --replace "watchfiles==0.15.0" "watchfiles>=0.14" \
									--replace "django==4.0.6" "django>=4.0" \
									--replace "django-picklefield==3.1" "django-picklefield>=3" \
									--replace "python-gnupg==0.4.9" "python-gnupg>=0.4" \
									--replace "threadpoolctl==3.1.0" "threadpoolctl>=3" \
									--replace "typing-extensions==4.3.0" "typing-extensions>=4" \
									--replace "-e git+https://github.com/paperless-ngx/django-q.git@bf20d57f859a7d872d5979cd8879fac9c9df981c#egg=django-q" "django-q"
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
								# needed for psycopg2
								echo "sphinx-better-theme" >> $out
    '');
in
mach-nix.mkPython {
  requirements = fixedReqFile;
  providers.pyzbar = "nixpkgs";
  providers.python-magic = "nixpkgs";
  providers.ocrmypdf = "nixpkgs";
  providers.pillow = "nixpkgs";
  providers.img2pdf = "nixpkgs";
	providers.psycopg2 = "nixpkgs";
	providers.black = "nixpkgs";
	providers.django = "nixpkgs";
	providers.sphinx-better-theme = "nixpkgs";
  _.numpy.buildInputs.add = [ pkgs.zlib ];
}
