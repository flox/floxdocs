{
  description = "Flox documentation - flox.dev/docs";

  nixConfig.extra-substituters = [
    "https://cache.flox.dev"
    "s3://flox-cache-private"
  ];
  nixConfig.extra-trusted-public-keys = [
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    "flox-cache-private-1:11kWWMbsoFjVfz0lSvRr8PRkFShcmvHDfnSGphvWKnk="
  ];

  inputs.nixpkgs.follows = "poetry2nix/nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";

  inputs.flox.url = "git+ssh://git@github.com/flox/flox?ref=refs/tags/v1.3.0";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    poetry2nix,
    flox,
  }:
    flake-utils.lib.eachDefaultSystem
    (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      inherit (pkgs) stdenv writeScriptBin runtimeShell lib fd gnused pandoc lychee poetry pngquant;

      inherit (poetry2nix.lib.mkPoetry2Nix {inherit pkgs;}) mkPoetryEnv overrides;

      pyEnv = mkPoetryEnv {
        projectDir = ./.;
        overrides = overrides.withDefaults (import ./overrides.nix);
      };

      pyProject = lib.importTOML ./pyproject.toml;

      checkCodeExamplesDeps = with pkgs; [
        git
        jq
        openssh
      ];
    in {
      packages.check-code-examples = writeScriptBin "check-code-examples" ''
        #!${runtimeShell}
        export PATH=${lib.makeBinPath checkCodeExamplesDeps}:$PATH
        exec ${pyEnv}/bin/tesh --verbose --no-debug \
          $PWD/docs/index.md \
          $PWD/docs/cookbook/validate-identical.md \
          $PWD/docs/tutorials/build-container-images.md \
          $PWD/docs/tutorials/managed-environments.md
      '';
      packages.default = stdenv.mkDerivation rec {
        name = pyProject.tool.poetry.name;
        version = pyProject.tool.poetry.version;

        src = self;

        FLOX_VERSION = flox.packages.${system}.flox-cli.version;

        postPatch = ''
          commandReferenceDir="$PWD/docs/reference/command-reference"
          mkdir -p "$commandReferenceDir"
          # includes in .md are relative
          pushd "${flox}/cli/flox/doc"
            fd "flox.*\.md" ./ -x \
              sh -c "
                pandoc -t gfm \
                  -L ${flox}/pkgs/flox-manpages/pandoc-filters/include-files.lua \
                  --standalone \
                  {} |
                  # remove current title
                  tail -n +6 |
                  # indent all markdown levels by one, e.g. "#" -> "##"
                  sed -e 's/^#/##/' > \"$commandReferenceDir/{/.}.md\"
              "
            fd "manifest.toml.md" ./ -x \
              sh -c "
                pandoc -t gfm \
                  -L ${flox}/pkgs/flox-manpages/pandoc-filters/include-files.lua \
                  --standalone \
                  {} |
                  # remove current title
                  tail -n +6 |
                  # indent all markdown levels by one, e.g. "#" -> "##"
                  sed -e 's/^#/##/' > \"$commandReferenceDir/{/.}.md\"
              "
          popd

          pushd $commandReferenceDir
            for commandPage in ./*.md; do
              # All other man page files have names of the form
              # 'flox*.md'
              if [ "$commandPage" = "./manifest.toml.md" ]; then
                continue
              fi
              command=$(basename $commandPage .md | sed -e "s|-| |g")
              echo -e "\n# \`$command\` command\n$(cat $commandPage)" > $commandPage
              echo -e "---\n$(cat $commandPage)" > $commandPage
              echo -e "description: Command reference for the \`$command\` command.\n$(cat $commandPage)" > $commandPage
              echo -e "title: $command\n$(cat $commandPage)" > $commandPage
              echo -e "---\n$(cat $commandPage)" > $commandPage
            done

            manifestPage="manifest.toml.md"
            echo -e "\n# \`manifest.toml\`\n$(cat $manifestPage)" > $manifestPage
            echo -e "---\n$(cat $manifestPage)" > $manifestPage
            echo -e "description: Reference for the manifest.toml format.\n$(cat $manifestPage)" > $manifestPage
            echo -e "title: manifest.toml\n$(cat $manifestPage)" > $manifestPage
            echo -e "---\n$(cat $manifestPage)" > $manifestPage
          popd
        '';

        shellHook =
          postPatch
          + ''
            echo Welcome to floxDocs
            echo
            echo For local preview run:
            echo   mkdocs serve
            echo
            echo For production build run:
            echo   mkdocs build
            echo
            echo Happy documenting!
          '';

        nativeBuildInputs = [
          pyEnv
          poetry
          gnused
          pandoc
          fd
          lychee
        ];

        buildInputs = [
          pngquant
        ];

        buildPhase = ''
          mkdocs build
        '';

        installPhase = ''
          lastmod=$(date -d @${builtins.toString self.lastModified} +"%Y-%m-%d")
          sed -i -e "s|1980-01-01|$lastmod|" site/sitemap.xml
          cp -R site $out
        '';
      };
    });
}
