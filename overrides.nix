final: prev: let
  addNativeBuildInputs = drvName: inputs: {
    "${drvName}" = prev.${drvName}.overridePythonAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ (builtins.map (i: prev."${i}") inputs);
    });
  };
  addPropagatedBuildInputs = drvName: inputs: {
    "${drvName}" = prev.${drvName}.overridePythonAttrs (old: {
      propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ (builtins.map (i: prev."${i}") inputs);
    });
  };
in
  {}
  // addNativeBuildInputs "mkdocs-include-markdown-plugin" ["hatchling"]
  // addPropagatedBuildInputs "mkdocs-include-dir-to-nav" ["setuptools"]
  // addNativeBuildInputs "tesh" ["poetry-core"]
  // addNativeBuildInputs "mkdocs-glightbox" ["setuptools"]
