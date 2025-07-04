{
  lib,
  buildPythonPackage,
  setuptools,
  wheel,
  pythonOlder,
  pytestCheckHook,
  fetchFromGitHub,
  python-dateutil,
  requests,
  pyyaml,
  beautifulsoup4,
  fetchPypi,
  fetchpatch,
  unidecode,
  regex,
  pytest,
  soupsieve,
}:

let
  semver_v2 = buildPythonPackage rec {
    pname = "semver";
    version = "2.13.0";
    format = "setuptools";
    doCheck = false;

    disabled = pythonOlder "3.6";

    src = fetchFromGitHub {
      owner = "python-semver";
      repo = "python-semver";
      rev = version;
      hash = "sha256-IWTo/P9JRxBQlhtcH3JMJZZrwAA8EALF4dtHajWUc4w=";
    };

    nativeCheckInputs = [
      pytestCheckHook
    ];

    postPatch = ''
      sed -i "/--cov/d" setup.cfg
      sed -i "/--no-cov-on-fail/d" setup.cfg
    '';

    disabledTestPaths = [
      # Don't test the documentation
      "docs/*.rst"
    ];

    pythonImportsCheck = [
      "semver"
    ];

    meta = with lib; {
      description = "Python package to work with Semantic Versioning (http://semver.org/)";
      homepage = "https://python-semver.readthedocs.io/";
      license = licenses.bsd3;
      maintainers = with maintainers; [ np ];
    };
  };

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
      semver_v2
    ];
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
      semver_v2
    ];
  };

  chardet_3 = buildPythonPackage rec {
    pname = "chardet";
    version = "3.0.4";

    src = fetchPypi {
      inherit pname version;
      sha256 = "1bpalpia6r5x1kknbk11p1fzph56fmmnp405ds8icksd3knr5aw4";
    };

    patches = [
      # Add pytest 4 support. See: https://github.com/chardet/chardet/pull/174
      (fetchpatch {
        url = "https://github.com/chardet/chardet/commit/0561ddcedcd12ea1f98b7ddedb93686ed8a5ffa4.patch";
        sha256 = "1y1xhjf32rdhq9sfz58pghwv794f3w2f2qcn8p6hp4pc8jsdrn2q";
      })
    ];

    # checkInputs = [
    #   pytest
    #   pytestrunner
    #   hypothesis
    # ];
    doCheck = false;

    meta = with lib; {
      homepage = "https://github.com/chardet/chardet";
      description = "Universal encoding detector";
      license = licenses.lgpl2;
      maintainers = with maintainers; [ domenkozar ];
    };
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
    chardet_3
    (buildPythonPackage rec {
      pname = "python-slugify";
      version = "1.2.6";

      src = fetchPypi {
        inherit pname version;
        sha256 = "7723daf30996db26573176bddcdf5fcb98f66dc70df05c9cb29f2c79b8193245";
      };
      # doCheck = !isPy3k;
      # (only) on python3 unittest loader (loadTestsFromModule) fails

      propagatedBuildInputs = [
        unidecode
        regex
      ];

      meta = with lib; {
        homepage = "https://github.com/un33k/python-slugify";
        description = "A Python Slugify application that handles Unicode";
        license = licenses.mit;
        platforms = platforms.all;
        maintainers = with maintainers; [ vrthra ];
      };
    })
    (buildPythonPackage rec {
      pname = "xlrd";
      version = "1.2.0";

      src = fetchPypi {
        inherit pname version;
        sha256 = "546eb36cee8db40c3eaa46c351e67ffee6eeb5fa2650b71bc4c758a29a1b29b2";
      };

      nativeCheckInputs = [
        pytestCheckHook
      ];
      checkInputs = [ pytest ];

      checkPhase = ''
        py.test -k "not test_tilde_path_expansion"
      '';

      meta = with lib; {
        homepage = "http://www.python-excel.org/";
        description = "Library for developers to extract data from Microsoft Excel (tm) spreadsheet files";
        license = licenses.bsd0;
      };

    })
    (buildPythonPackage rec {
      pname = "dbfread";
      version = "2.0.4";
      format = "setuptools";

      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-eUB9XuSOzeB+rweh+NFb6FX64laLzSxpw8n7fqxo8DY=";
      };

      meta = with lib; {
        description = "Read DBF Files with Python";
        homepage = "https://dbfread.readthedocs.org/";
        license = with licenses; [ mit ];
        maintainers = [ ];
      };
    })
    (buildPythonPackage rec {
      pname = "ijson";
      version = "2.6.1";

      src = fetchPypi {
        inherit pname version;
        sha256 = "1l034zq23315icym2n0zppa5lwpdll3mvavmyjbiryxb4c5wdsvm";
      };

      doCheck = false; # something about yajl

      meta = with lib; {
        description = "Iterative JSON parser with a standard Python iterator interface";
        homepage = "https://github.com/ICRAR/ijson";
        license = licenses.bsd3;
        maintainers = with maintainers; [ rvl ];
      };
    })
    requests
    (beautifulsoup4.overridePythonAttrs (old: {
      propagatedBuildInputs = [
        chardet_3
        soupsieve
      ];
    }))
    pygogo
    pyyaml
    python-dateutil
  ];

  # specific to buildPythonPackage, see its reference
  pyproject = true;
  build-system = [
    setuptools
    wheel
    semver_v2
    pkutils
  ];
}
