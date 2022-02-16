{
  inputs = {
    mach-nix.url = "mach-nix/c914064c9b8cab9495818ffe8d834d8c2c1d7ce7";
  };

  outputs = { self, nixpkgs, mach-nix }@inp:
    let

      l = nixpkgs.lib // builtins;
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: l.genAttrs supportedSystems
        (system: f system (import nixpkgs { inherit system; }));
    in
    {
      # enter this python environment by executing `nix shell .`
      defaultPackage = forAllSystems (system: pkgs: mach-nix.lib."${system}".mkPython {
        requirements = builtins.readFile ./requirements.txt;
        python = "python39";
        #_.numpy.buildInputs.add = [ mach-nix.nixpkgs.cython ];
        _.psyycopcg2.buildInputs.add = [ nixpkgs.postgresql ];
        providers = {
          _default = "nixpkgs,sdist";
          lxml = "sdist";
          psyycopcg2 = "nixpkgs";
        };
        #overridesPost = [
        # (self: super: {
        #   numpy = super.numpy.overrideAttrs (attrs: {
        #    nativeBuildInputs = attrs.nativeBuildInputs ++ [ mach-nix.cython ];
        #  });
        #})
        #];
      });
    };
}
