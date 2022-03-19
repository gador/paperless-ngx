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
    	--replace "setuptools==60.9.3" "setuptools>=57"
    '');
in
mach-nix.mkPython {
  requirements = fixedReqFile;
}
