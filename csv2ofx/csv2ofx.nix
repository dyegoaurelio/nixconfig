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
    rev = "5094718b5099cbd36c2c6eb940d9202f741b1e71";
    sha256 = "sha256-rYvuCIWWgTt3HY+unmIqYPt7bVhrWbeSXcI3VDOoyaE=";
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
