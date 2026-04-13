{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      hsPkgs = pkgs.haskell.packages.ghc98;
      occt = pkgs.opencascade-occt;
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          hsPkgs.ghc
          hsPkgs.cabal-install
          hsPkgs.haskell-language-server
          hsPkgs.hpack
          pkgs.stack
          occt
          pkgs.zlib
          pkgs.pkg-config
        ];

        shellHook = ''
          export C_INCLUDE_PATH="${occt}/include/opencascade''${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
          export CPLUS_INCLUDE_PATH="${occt}/include/opencascade''${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
          export LIBRARY_PATH="${occt}/lib''${LIBRARY_PATH:+:$LIBRARY_PATH}"
          export LD_LIBRARY_PATH="${occt}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        '';
      };
    };
}
