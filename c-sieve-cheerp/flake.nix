{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) stdenv;
        cheerp = stdenv.mkDerivation {
          name = "cheerp";
          pname = "cheerp";
          version = "0.1";

          src = pkgs.fetchFromGitHub {
            repo = "cheerp-compiler";
            owner = "leaningtech";
            rev = "7e39cae34e6cc4e5ab59a0ba3be7bfd37d06b520";
            sha256 = "yDX5Pq2bKrArwAYNkjWHCJNHHK20LB6kl10FqKaPaxY=";
          };


          # See https://ryantm.github.io/nixpkgs/hooks/cmake/#cmake
          # and https://github.com/NixOS/nixpkgs/issues/344336 for more information
          dontUseCmakeConfigure = true;

          buildInputs = with pkgs; [
            cmake
            python312
            python312Packages.distutils-extra
            ninja
            libgcc
            lld
            git
          ];

          buildPhase = ''
            cmake -DCMAKE_INSTALL_PREFIX="$out" -S llvm -B build -C llvm/CheerpCmakeConf.cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS=clang -G Ninja
            ninja -C build
          '';

          installPhase = ''
            ninja -C build install
          '';
        };
      in
      {
        defaultPackage = cheerp;
        devShells.default = pkgs.mkShell { packages = [ 
          pkgs.bashInteractive 
          pkgs.nodejs
          pkgs.wabt
        ];};
      }
    );
}
