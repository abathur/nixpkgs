{ lib
, buildPythonPackage
, fetchFromGitHub
, jinja2
, pyyaml
, setuptools
, mock
}:

buildPythonPackage rec {
  pname = "PyCG";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "vitsalis";
    repo = pname;
    rev = "0c9884b7064bba1ecda64ec323b6ccaae4fec521";
    hash = "sha256-TV9LxFntK1huK78PUgrM61BfKpeAb1QSe0bMy3gHohQ=";
  };

  propagatedBuildInputs = [ setuptools ];

  checkInputs = [ mock ];
  checkPhase = ''
    make test
  '';

  meta = with lib; {
    homepage = "https://github.com/vitsalis/PyCG";
    description = "Static Python call graph generator";
    license = licenses.bsd2;
    longDescription = ''
      PyCG generates call graphs for Python code using static analysis. It efficiently supports
      - Higher order functions
      - Twisted class inheritance schemes
      - Automatic discovery of imported modules for further analysis
      - Nested definitions
    '';
    maintainers = with maintainers; [ abathur ];
  };

}
