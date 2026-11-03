{
  description = "wowless development environment";

  inputs.nixpkgs.url = "https://channels.nixos.org/nixos-26.05/nixexprs.tar.xz";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
      tools =
        pkgs: with pkgs; [
          # Build system.
          cmake
          git
          ninja

          # vcpkg bootstrap and port builds.
          autoconf
          autoconf-archive
          automake
          curl
          gnumake
          libtool
          perl
          pkg-config
          # pre-commit runs its meta hooks with its own interpreter, so it
          # must be importable from the python on PATH.
          (python3.withPackages (ps: [
            ps.jinja2
            (ps.toPythonModule pre-commit)
          ]))
          unzip
          zip

          # pre-commit system/ruby hooks.
          lua51Packages.luacheck
          ruby
        ];
    in
    {
      # `nix develop`: the tools plus the stdenv compiler toolchain.
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell { packages = tools pkgs; };
      });

      # The same tools as a plain profile, installed into the devcontainer
      # image and put on PATH there. mkShell's toolchain is added explicitly
      # since a profile does not get it from stdenv.
      packages = forAllSystems (pkgs: {
        devcontainer = pkgs.symlinkJoin {
          name = "wowless-devcontainer";
          paths = tools pkgs ++ [
            pkgs.binutils
            pkgs.stdenv.cc
          ];
        };
      });
    };
}
