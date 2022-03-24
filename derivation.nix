{ lib
, fetchurl
, nixosTests
, python3
, ghostscript
, imagemagick
, jbig2enc
, optipng
, pngquant
, qpdf
, tesseract4
, unpaper
, liberation_ttf
, poppler_utils
}:

let
  py = python3.override {
    packageOverrides = self: super: {
      django = super.django_3;
      django-picklefield = super.django-picklefield.overrideAttrs (oldAttrs: {
        # Checks do not pass with django 3
        doInstallCheck = false;
      });
      # Avoid warning in django-q versions > 1.3.4
      # https://github.com/jonaswinkler/paperless-ng/issues/857
      # https://github.com/Koed00/django-q/issues/526
      django-q = super.django-q.overridePythonAttrs (oldAttrs: rec {
        version = "1.3.4";
        src = oldAttrs.src.override {
          inherit version;
          sha256 = "Uj1U3PG2YVLBtlj5FPAO07UYo0MqnezUiYc4yo274Q8=";
        };
      });

      # Incompatible with aioredis 2
      aioredis = super.aioredis.overridePythonAttrs (oldAttrs: rec {
        version = "1.3.1";
        src = oldAttrs.src.override {
          inherit version;
          sha256 = "0fi7jd5hlx8cnv1m97kv9hc4ih4l8v15wzkqwsp73is4n0qazy0m";
        };
      });
      # wait for https://github.com/NixOS/nixpkgs/pull/165382
      ocrmypdf = super.ocrmypdf.overridePythonAttrs (oldAttrs: rec {
        postPatch = ''
          # https://github.com/ocrmypdf/OCRmyPDF/issues/933
          substituteInPlace setup.cfg \
            --replace "pdfminer.six!=20200720,>=20191110,<=20211012" "pdfminer.six"
        '';
      });
      pdfminer_six = super.pdfminer_six.overridePythonAttrs (oldAttrs: rec {
        version = "20220319";
        postPatch = ''
          # Verion is not stored in repo, gets added by a GitHub action after tag is created
          # https://github.com/pdfminer/pdfminer.six/pull/727
          substituteInPlace pdfminer/__init__.py --replace "__VERSION__" ${version}
        '';
      });

    };
  };
  path = lib.makeBinPath [ ghostscript imagemagick jbig2enc optipng pngquant qpdf tesseract4 unpaper poppler_utils ];
in
py.pkgs.pythonPackages.buildPythonApplication rec {
  pname = "paperless-ngx";
  version = "1.6.1wip";

  src = ./.;
  format = "other";

  # Make bind address configurable
  postPatch = ''
    substituteInPlace gunicorn.conf.py --replace "bind = f'0.0.0.0:{os.getenv(\"PAPERLESS_PORT\", 8000)}'" ""
  '';

  propagatedBuildInputs = with py.pkgs.pythonPackages; [
    aioredis
    arrow
    asgiref
    async-timeout
    attrs
    autobahn
    automat
    blessed
    certifi
    cffi
    channels-redis
    channels
    chardet
    click
    coloredlogs
    concurrent-log-handler
    constantly
    cryptography
    daphne
    dateparser
    django-cors-headers
    django-extensions
    django-filter
    django-picklefield
    django-q
    django
    djangorestframework
    filelock
    fuzzywuzzy
    gunicorn
    h11
    hiredis
    httptools
    humanfriendly
    hyperlink
    idna
    imap-tools
    img2pdf
    incremental
    inotify-simple
    inotifyrecursive
    joblib
    langdetect
    lxml
    msgpack
    numpy
    ocrmypdf
    pathvalidate
    pdfminer
    pikepdf
    pillow
    pluggy
    portalocker
    psycopg2
    pyasn1-modules
    pyasn1
    pycparser
    pyopenssl
    python-dateutil
    python-dotenv
    python-gnupg
    python-Levenshtein
    python_magic
    pytz
    pyyaml
    redis
    regex
    reportlab
    requests
    scikit-learn
    scipy
    service-identity
    six
    sortedcontainers
    sqlparse
    threadpoolctl
    tika
    tqdm
    twisted.extras.tls
    txaio
    tzlocal
    urllib3
    uvicorn
    uvloop
    watchdog
    watchgod
    wcwidth
    websockets
    whitenoise
    whoosh
    zope_interface
    pyzbar
		pdf2image
  ];

  doCheck = true;
  checkInputs = with py.pkgs.pythonPackages; [
    pytest
    pytest-cov
    pytest-django
    pytest-env
    pytest-sugar
    pytest-xdist
    factory_boy
  ];

  # The tests require:
  # - PATH with runtime binaries
  # - A temporary HOME directory for gnupg
  # - XDG_DATA_DIRS with test-specific fonts
  checkPhase = ''
    pushd src
    PATH="${path}:$PATH" HOME=$(mktemp -d) XDG_DATA_DIRS="${liberation_ttf}/share:$XDG_DATA_DIRS" pytest
    popd
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp -r . $out/lib/paperless-ngx
    chmod +x $out/lib/paperless-ngx/src/manage.py
    makeWrapper $out/lib/paperless-ngx/src/manage.py $out/bin/paperless-ngx \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --prefix PATH : "${path}"
  '';

  passthru = {
    # PYTHONPATH of all dependencies used by the package
    pythonPath = python3.pkgs.makePythonPath propagatedBuildInputs;
    inherit path;

    tests = { inherit (nixosTests) paperless-ng; };
  };

  meta = with lib; {
    description = "A supercharged version of paperless: scan, index, and archive all of your physical documents";
    homepage = "https://paperless-ng.readthedocs.io/en/latest/";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ earvstedt Flakebi ];
  };
}
