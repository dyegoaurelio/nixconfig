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
    rev = "1750a4b76324c353ff4838b0e67998b6a2cfb2b5";
    sha256 = "sha256-Iw8irouVXN/7812ECjv4g8ay6KHC94K4Y7JvOXnS408=";
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
