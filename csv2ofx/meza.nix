{
  buildPythonPackage,
  fetchFromGitHub,

  setuptools,
  wheel,
  python-dateutil,
  requests,
  pyyaml,
  beautifulsoup4,
  semver,
  chardet,
  ijson,
  dbfread,
  python-slugify,
  xlrd,
}:

let
  pkutils = buildPythonPackage rec {
    pname = "pkutils";
    version = "3.0.2";
    src = fetchFromGitHub {
      owner = "reubano";
      repo = "pkutils";
      rev = "v${version}";
      sha256 = "sha256-AK+xX+LPz6IVLZedsqMUm7G28ue0s3pXgIzxS4EHHLE=";
    };

    pyproject = true;
    build-system = [
      setuptools
      wheel
      semver
    ];
    pythonRelaxDeps = [ "semver" ];
  };

  pygogo = buildPythonPackage rec {
    pname = "pygogo";
    version = "1.2.0";
    src = fetchFromGitHub {
      owner = "reubano";
      repo = "pygogo";
      rev = "v${version}";
      sha256 = "sha256-IZCaaPEcqNB+ABKlQVrXr/lRfHO9z3N42YyiAFRe4Eo=";
    };

    pyproject = true;
    build-system = [
      setuptools
      wheel
      pkutils
      semver
    ];
    pythonRelaxDeps = [ "semver" ];
  };

in

buildPythonPackage rec {
  pname = "meza";
  version = "0.47.0";
  src = fetchFromGitHub {
    owner = "reubano";
    repo = "meza";
    rev = "v${version}";
    sha256 = "sha256-/+4BDUrtZUvXQTHk9IJ3hsl07sAkqSl8eczK1efF+fc=";
  };

  propagatedBuildInputs = [
    chardet
    python-slugify
    xlrd
    dbfread
    ijson
    requests
    beautifulsoup4
    pygogo
    pyyaml
    python-dateutil
  ];

  pythonRelaxDeps = [
    "chardet"
    "python-slugify"
    "xlrd"
    "dbfread"
    "ijson"
    "semver"
  ];

  pyproject = true;
  build-system = [
    setuptools
    wheel
    semver
    pkutils
  ];
}
