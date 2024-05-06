{
  description = "My parity env";

  inputs = {
    honggfuzz = {
      url = "github:rust-fuzz/honggfuzz-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, honggfuzz }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      myrust = with fenix.packages.${system}; with stable; combine [
        cargo
        clippy
        rust-src
        rustc
        latest.rustfmt
        targets.wasm32-unknown-unknown.stable.rust-std
      ];
    in {
      devShells.default = pkgs.mkShell {
        name = "honggfuzz-shell";

        packages = with pkgs; [
          libbfd
          bintools-unwrapped
          libunwind

          honggfuzz.packages.honggfuzz-rs
        ];

        # Fortify causes build failures: 'str*' defined both normally and as 'alias' attribute
        hardeningDisable = [ "fortify" ];
      };
    }
  );
}
