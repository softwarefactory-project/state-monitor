{
  description = "state-monitor";
  nixConfig.bash-prompt = "[nix(state-monitor)] ";

  inputs = {
    hspkgs.url =
      "github:podenv/hspkgs/4a25962c7beede6cfcacc66000ef783e5c98e483";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, hspkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        packageName = "state-monitor";
        pkgs = hspkgs.pkgs;
        haskellPackages = pkgs.hspkgs;
        myPackage = haskellPackages.callCabal2nix packageName self { };
        appExe = pkgs.haskell.lib.justStaticExecutables myPackage;

      in {
        defaultExe = appExe;
        defaultPackage = myPackage;

        devShell = haskellPackages.shellFor {
          packages = p: [ myPackage ];

          buildInputs = [
            pkgs.ghcid
            pkgs.ormolu
            pkgs.cabal-install
            pkgs.hlint
            pkgs.haskell-language-server
          ];
        };
      });
}
