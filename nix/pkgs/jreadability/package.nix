{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "jreadability";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "joshdavham";
    repo = "jreadability";
    rev = "v${version}";
    sha256 = "sha256-T9xu3IVB0oIuz3MfguQ3iRHEuQf0bqIXz4x1/+FiJ7A=";
  };

  pyproject = true;
  build-system = with python3Packages; [
    setuptools
  ];

  propagatedBuildInputs = with python3Packages; [
    fugashi
    unidic-lite
  ];

  doCheck = false;

  # 👇 Add wrapper executable
  postInstall = /* python */ ''
    mkdir -p $out/bin

    cat > $out/bin/jr <<'EOF'
    #!${python3Packages.python.interpreter}
    import sys
    import json
    from jreadability import compute_readability

    def read_input():
        if len(sys.argv) > 1:
            path = sys.argv[1]
            with open(path, "r", encoding="utf-8") as f:
                return f.read()
        else:
            return sys.stdin.read()

    def level_name(score: float) -> str:
        if 0.5 <= score < 1.5:
            return "Upper-advanced"
        if 1.5 <= score < 2.5:
            return "Lower-advanced"
        if 2.5 <= score < 3.5:
            return "Upper-intermediate"
        if 3.5 <= score < 4.5:
            return "Lower-intermediate"
        if 4.5 <= score < 5.5:
            return "Upper-elementary"
        if 5.5 <= score < 6.5:
            return "Lower-elementary"
        return "Out of range"

    def extract_score(result):
        if isinstance(result, (int, float)):
            return float(result)
        if isinstance(result, dict):
            # common patterns
            for key in ("score", "readability", "difficulty"):
                if key in result:
                    return float(result[key])
        raise ValueError("Could not extract readability score")

    def main():
        text = read_input().strip()
        if not text:
            print("jr: no input provided", file=sys.stderr)
            sys.exit(1)

        result = compute_readability(text)

        try:
            score = extract_score(result)
            level = level_name(score)
        except Exception as e:
            print(f"jr: error extracting score: {e}", file=sys.stderr)
            sys.exit(2)

        print(f"Score: {score:.2f}")
        print(f"Level: {level}")
        print()
        print("Raw result:")
        print(json.dumps(result, ensure_ascii=False, indent=2))

    if __name__ == "__main__":
        main()
    EOF

    chmod +x $out/bin/jr
  '';

  meta = with lib; {
    description = "Text readability calculator for Japanese learners (with jr CLI)";
    homepage = "https://github.com/joshdavham/jreadability";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
