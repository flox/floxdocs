{
  inputs,
  lib,
  writeScriptBin,
  runtimeShell,
  pkgs,
}: let
  deps = with pkgs; [
    git
    jq
    openssh
    inputs.flox-floxpkgs.packages.tracelinks
  ];
in writeScriptBin "check-code-examples" ''
  #!${runtimeShell}
  export PATH=${lib.makeBinPath deps}:$PATH
  exec tesh --verbose --no-debug \
    $PWD/docs/index.md \
    $PWD/docs/cookbook/validate-identical.md \
    $PWD/docs/tutorials/build-container-images.md \
    $PWD/docs/tutorials/managed-environments.md
''
