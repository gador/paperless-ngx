{
  description = "Flake for paperless-ngx";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
    flake-utils = { url = "github:numtide/flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        python = pkgs.python39;
        projectDir = ./.;
        overrides = [
          pkgs.poetry2nix.defaultPoetryOverrides
          (self: super: {
            pikepdf = super.pikepdf.overrideAttrs (old: {
              nativeBuildInputs = old.nativeBuildInputs ++ [ self.setuptools-scm-git-archive self.pybind11 ];
              buildInputs = old.buildInputs ++ [ self.pybind11 self.setuptools-scm-git-archive pkgs.qpdf ];
            });
          })
          (self: super: {
            threadpoolctl = super.threadpoolctl.overrideAttrs (old: {
              format = "other";
              buildPhase = ''
                runHook preBuild
                ${python}/bin/python -m flit build --format wheel
                runHook postBuild
              '';
              installPhase = ''
                ${self.pip}/bin/pip install dist/*.whl --prefix $out
              '';
              nativeBuildInputs = [ self.flit self.flit-core self.wrapPython ];
              #buildInputs = [ self.flit ];
            });
          })
          (self: super: {
            ocrmypdf = super.ocrmypdf.overrideAttrs (old: {
              nativeBuildInputs = old.nativeBuildInputs ++ [ self.setuptools-scm-git-archive ];
            });
          })
        ];
        packageName = "paperless-ngx";
        path = pkgs.lib.makeBinPath [
          pkgs.ghostscript
          pkgs.imagemagick
          pkgs.jbig2enc
          pkgs.optipng
          pkgs.pngquant
          pkgs.qpdf
          pkgs.tesseract4
          pkgs.unpaper
        ];

      in
      {

        packages.${packageName} = pkgs.poetry2nix.mkPoetryApplication {
          inherit python projectDir;
          overrides = overrides;
          format = "other";
          postPatch = ''
            substituteInPlace gunicorn.conf.py --replace "bind = '0.0.0.0:8000'" ""
          '';
          buildPhase = ''
            true
          '';
          installPhase = ''
            mkdir -p $out/lib
            cp -r . $out/lib/paperless-ng
            chmod +x $out/lib/paperless-ng/src/manage.py
            makeWrapper $out/lib/paperless-ng/src/manage.py $out/bin/paperless-ng \
            --prefix PYTHONPATH : "$PYTHONPATH" \
            --prefix PATH : "${path}"
          '';

        };

        defaultPackage = self.packages.${system}.${packageName};

        devShell = pkgs.mkShell
          {
            buildInputs = [
              (pkgs.poetry2nix.mkPoetryEnv {
                inherit python projectDir overrides;
                #editablePackageSources = { paperless-ngx = "./src/"; };
                extraPackages = ps: [ pkgs.imagemagick ];
              })
              pkgs.python39Packages.poetry
            ];
          };

      });
}
