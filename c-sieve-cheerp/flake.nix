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

          srcs = [
            (pkgs.fetchFromGitHub {
              repo = "cheerp-compiler";
              owner = "leaningtech";
              name = "cheerp-compiler";
              rev = "7e39cae34e6cc4e5ab59a0ba3be7bfd37d06b520";
              sha256 = "yDX5Pq2bKrArwAYNkjWHCJNHHK20LB6kl10FqKaPaxY=";
            })
            (pkgs.fetchFromGitHub {
              repo = "cheerp-utils";
              owner = "leaningtech";
              name = "cheerp-utils";
              rev = "9e8175c075212b93ace9c4c5d380cac9c19933c2";
              sha256 = "82XcTJglNrdLZfGHRpNUd8GxRKioID0N9uKti6mr7xc=";
            })
            (pkgs.fetchFromGitHub {
              repo = "cheerp-musl";
              owner = "leaningtech";
              name = "cheerp-musl";
              rev = "f2efa18e9cfe260f30841ecb80b167ae940fc022";
              sha256 = "NvYCPIVhdP5Ic/l6w/HAcyTBSrmb3/ntk0hbf6KhWPI=";
            })
            (pkgs.fetchFromGitHub {
              repo = "cheerp-libs";
              owner = "leaningtech";
              name = "cheerp-libs";
              rev = "fa75abee48205f5a8df271faa30734b23756d79d";
              sha256 = "qUpyqbfk1+j68q/yAPkb7SaC50J56SKpIirbG2kpcWc=";
            })
          ];

          sourceRoot = ".";

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

          configurePhase = ''
            export CHEERP_DEST=$out
          '';

          buildPhase = ''
            cd cheerp-compiler
            cmake -DCMAKE_INSTALL_PREFIX="$CHEERP_DEST" -S llvm -B build -C llvm/CheerpCmakeConf.cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS=clang -G Ninja
            ninja -C build
          '';

          installPhase = ''
            ninja -C build install
            cd ..
          '';

          fixupPhase = ''
            cd cheerp-utils
            cmake -B build -DCMAKE_INSTALL_PREFIX="$CHEERP_DEST" .
            make -C build install
            cd ..

            cd cheerp-musl
            mkdir build_genericjs
            cd build_genericjs
            RANLIB="$CHEERP_DEST/bin/llvm-ar s" AR="$CHEERP_DEST/bin/llvm-ar"  CC="$CHEERP_DEST/bin/clang -target cheerp" LD="$CHEERP_DEST/bin/llvm-link" CFLAGS="-Wno-int-conversion" ../configure --target=cheerp --disable-shared --prefix="$CHEERP_DEST" --with-malloc=dlmalloc
            make -j
            make install
            cd ..
            mkdir build_asmjs
            cd build_asmjs
            RANLIB="$CHEERP_DEST/bin/llvm-ar s" AR="$CHEERP_DEST/bin/llvm-ar"  CC="$CHEERP_DEST/bin/clang -target cheerp-wasm" LD="$CHEERP_DEST/bin/llvm-link" CFLAGS="-Wno-int-conversion" ../configure --target=cheerp-wasm --disable-shared --prefix="$CHEERP_DEST" --with-malloc=dlmalloc
            make -j
            make install
            cd ../..

            cd cheerp-compiler
            cmake -DCMAKE_INSTALL_PREFIX="$CHEERP_DEST" -S runtimes -B build_runtimes_genericjs -GNinja -C runtimes/CheerpCmakeConf.cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE="$CHEERP_DEST/share/cmake/Modules/CheerpToolchain.cmake"
            ninja -C build_runtimes_genericjs

            cmake -DCMAKE_INSTALL_PREFIX="$CHEERP_DEST" -S runtimes -B build_runtimes_wasm -GNinja -C runtimes/CheerpCmakeConf.cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE="$CHEERP_DEST/share/cmake/Modules/CheerpWasmToolchain.cmake"
            ninja -C build_runtimes_wasm

            ninja -C build_runtimes_genericjs install
            ninja -C build_runtimes_wasm install
            cd ..

            cd cheerp-libs
            make -C webgles install INSTALL_PREFIX="$CHEERP_DEST" CHEERP_PREFIX="$CHEERP_DEST"
            make -C wasm install INSTALL_PREFIX="$CHEERP_DEST" CHEERP_PREFIX="$CHEERP_DEST"
            make -C stdlibs install INSTALL_PREFIX="$CHEERP_DEST" CHEERP_PREFIX="$CHEERP_DEST"
            cd system
            cmake -B build_genericjs -DCMAKE_INSTALL_PREFIX="$CHEERP_DEST" -DCMAKE_TOOLCHAIN_FILE="$CHEERP_DEST/share/cmake/Modules/CheerpToolchain.cmake" .
            cmake --build build_genericjs
            cmake --install build_genericjs
            cmake -B build_asmjs -DCMAKE_INSTALL_PREFIX="$CHEERP_DEST" -DCMAKE_TOOLCHAIN_FILE="$CHEERP_DEST/share/cmake/Modules/CheerpWasmToolchain.cmake" .
            cmake --build build_asmjs
            cmake --install build_asmjs
            cd ../..

            cd cheerp-compiler/compiler-rt
            cmake -DCMAKE_INSTALL_PREFIX="$CHEERP_DEST" -B build -C CheerpCmakeConf.cmake -DCMAKE_TOOLCHAIN_FILE="$CHEERP_DEST/share/cmake/Modules/CheerpWasmToolchain.cmake" .
            make -C build install # parallel builds do NOT work
          '';
        };
      in
      {
        defaultPackage = cheerp.packages.${system};
        # defaultPackage = cheerp;

        devShells.default = pkgs.mkShell { 
          packages = let
            cheerp = cheerp.packages.${system};
          in[ 
            pkgs.bashInteractive 
            pkgs.nodejs
            pkgs.wabt
        ];
      };
      }
    );
}
