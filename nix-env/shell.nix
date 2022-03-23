
with (import ./inputs.nix);
pkgs.mkShell {
	shellHook = ''
     XDG_DATA_DIRS="${pkgs.liberation_ttf}/share:$XDG_DATA_DIRS"
  '';
  buildInputs = [
    (import ./python.nix)
    mach-nix.mach-nix
		pkgs.optipng
		pkgs.ghostscript
		pkgs.imagemagick
		pkgs.jbig2enc
		pkgs.pngquant
		pkgs.qpdf
		pkgs.tesseract4
		pkgs.unpaper
  ];
}
