{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    nix_main.url = "github:NixOS/nix";
  };

  outputs =
    { self
    , nixpkgs
    , utils
    , naersk
    , nix_main
    }:
    utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { inherit system; };
      naersk-lib = pkgs.callPackage naersk { };
      nix = nix_main.packages.${system}.nix;
    in
    {
      defaultPackage = naersk-lib.buildPackage {
        pname = "nix-expr-c-sys";
        src = ./.;

        nativeBuildInputs = with pkgs; [ pkg-config libclang ] ++ [ nix ];
        buildInputs = [ nix ];

        LIBCLANG_PATH = "${pkgs.llvmPackages_latest.libclang.lib}/lib";
      };
      devShell = with pkgs; mkShell {
        nativeBuildInputs = [ nix ];
        buildInputs = [
          cargo
          rustc
          rustfmt
          pre-commit
          rustPackages.clippy
          cargo-flamegraph
          cargo-dist

          pkg-config
          clang
        ];
        RUST_SRC_PATH = rustPlatform.rustLibSrc;
        LIBCLANG_PATH = "${pkgs.llvmPackages_latest.libclang.lib}/lib";
      };
    });
}
