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
        overrides = pkgs.poetry2nix.overrides.withDefaults (self: super: {
          threadpoolctl = super.threadpoolctl.overrideAttrs (old: {
            format = "flit";
          });
        });

        packageName = "paperless-ngx";
      in
      {

        packages.${packageName} = pkgs.poetry2nix.mkPoetryApplication {
          inherit python projectDir;
          # Non-Python runtime dependencies go here
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
          ];
          propogatedBuildInputs = [ pkgs.python3Packages.setuptools-scm-git-archive ];
          buildInputs = [ pkgs.python3Packages.pybind11 ];
        };

        defaultPackage = self.packages.${system}.${packageName};

        devShell = pkgs.mkShell
          {
            buildInputs = [
              (pkgs.poetry2nix.mkPoetryEnv {
                inherit python projectDir overrides;
              })
              pkgs.python39Packages.poetry
            ];
          };

      });
}
