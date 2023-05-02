{
  description = "dpc's basic flake template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, crane, fenix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        craneLib = crane.lib.${system};

        commonArgs = {
          src = craneLib.cleanCargoSource ./.;

          buildInputs = [ ];

          nativeBuildInputs = [ ];
        };
      in
      {
        packages.default = craneLib.buildPackage ({ } // commonArgs);

        devShells = {
          default = pkgs.mkShell {

            buildInputs = [ ] ++ commonArgs.buildInputs;
            nativeBuildInputs = builtins.attrValues
              {
                inherit (pkgs) cargo rustc nixpkgs-fmt shellcheck rnix-lsp;
              } ++ [
              # This is required to prevent a mangled bash shell in nix develop
              # see: https://discourse.nixos.org/t/interactive-bash-with-nix-develop-flake/15486
              (pkgs.hiPrio pkgs.bashInteractive)
              pkgs.nodePackages.bash-language-server

            ] ++ commonArgs.nativeBuildInputs;
            shellHook = ''
              dot_git="$(git rev-parse --git-common-dir)"
              if [[ ! -d "$dot_git/hooks" ]]; then mkdir "$dot_git/hooks"; fi
              for hook in misc/git-hooks/* ; do ln -sf "$(pwd)/$hook" "$dot_git/hooks/" ; done
              ${pkgs.git}/bin/git config commit.template $(pwd)/misc/git-hooks/commit-template.txt
            '';
          };
        };
      }
    );
}
