{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "csv2ofx";
  version = "0.34.0-PATCH";

  src = fetchFromGitHub {
    owner = "dyegoaurelio";
    repo = "csv2ofx";
    rev = "a3f4c83a4b69f937150a5009975166e8a0e0e61f";
    sha256 = "sha256-3k8u6RuwT5imsdGSRb7Pl+TcAddOj5xBUtH9glPbk1A=";
  };

  propagatedBuildInputs = with python3Packages; [
    meza
    python-dateutil
    requests
  ];

  pyproject = true;
  build-system = with python3Packages; [
    setuptools
    wheel
  ];

  meta = with lib; {
    homepage = "https://github.com/reubano/csv2ofx";
    description = "A Python library and command line tool for converting csv to ofx and qif files ";
    license = licenses.mit;
    maintainers = with maintainers; [ dyegoaurelio ];
  };
}
