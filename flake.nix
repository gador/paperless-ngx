{
  description = "Nix FHS for paperless-ngx";

	inputs.nixpkgs.url = "github:gador/nixpkgs/current";

  outputs = all@{ self,  nixpkgs, ... }:
    let
      system = "x86_64-linux";
			venv = ".venv";
      overlays = [ ];
      pkgs = import nixpkgs {
        inherit system overlays;
        config.allowUnfree = true;
      };
      fhs_env = pkgs.buildFHSUserEnv {
        name = "pipzone";
        targetPkgs = pkgs:
          (with pkgs; [
            python310
            python310Packages.pip
            python310Packages.virtualenv
            pipenv
            optipng
            ghostscript
            imagemagick
            jbig2enc
            pngquant
            qpdf
            tesseract4
            unpaper
            poppler_utils
            black
            zlib
            mysql80
            libmysqlclient
            gcc
          ]);
        runScript = ''
				# run with nix run .#fhs
				# the .venv needs to be created first
				if [[ ! -d "${venv}" ]]
				then
					python -m venv ${venv}
					source ${venv}/bin/activate
					pipenv install --dev
					patch ${venv}/lib/python3.10/site-packages/magic/loader.py ${patch} || echo "patch could not be applied"
					sed -i -e "s|find_library('zbar')|\"${pkgs.lib.getLib pkgs.zbar}/lib/libzbar${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}\"|" \
					  ${venv}/lib/python3.10/site-packages/pyzbar/zbar_library.py
				else
					source ${venv}/bin/activate
				fi
				XDG_DATA_DIRS="${pkgs.liberation_ttf}/share:$XDG_DATA_DIRS"
        bash
				'';
      };
			patch = pkgs.substituteAll {
      src = ./libmagic-path.patch;
      libmagic = "${pkgs.file}/lib/libmagic${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";
    };
    in
    {
			fhs = fhs_env;
    };
}
