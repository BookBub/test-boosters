with (import (fetchTarball {
  name = "nixpkgs-2021-01-05";
  url = "https://github.com/nixos/nixpkgs/archive/f35bf8ef29d2bd9e4f1a915202de355e126a9ffd.tar.gz";
  # obtained by running nix-prefetch-url --name <name> --unpack <url>
  sha256 = "0a9farbkwf1fnf112ldvn5pdlghnnsdx2bih26zaanc6ah120abs";
}) {});

let
  requiredNixVersion = "2.3";
  pwd = builtins.getEnv "PWD";
in

if stdenv.lib.versionOlder builtins.nixVersion requiredNixVersion == true then
  abort "This project requires Nix >= ${requiredNixVersion}, please run 'nix-channel --update && nix-env -i nix'."
else


  mkShell {
    buildInputs = [
      stdenv
      git
      awscli
      cacert

      # Ruby and Rails dependencies
      ruby_2_6
      bundler
      openssl
      clang
      libxml2
      libxslt
      libiconv

    ] ++ stdenv.lib.optional (!stdenv.isDarwin) [
      # linux-only packages
      glibcLocales
    ];


    BUNDLE_PATH = "vendor/bundle";
    NIX_PROJECT = builtins.baseNameOf pwd;
  }
