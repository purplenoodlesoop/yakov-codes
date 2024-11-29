{ pkgs, ... }:
let
  inherit (pkgs)
    buildDartApplication
    lib
    ;
  lock = "pubspec.lock";
  lockJson = "${lock}.json";
in
{
  flake = {
    packages.default = buildDartApplication {
      version = "1.0.0";
      pname = "generator";
      src = ./.;
      pubspecLock = lib.importJSON ./${lockJson};
    };
    shell = with pkgs; [
      yq
      dart
    ];
  };

  tasks.gen-pubspec-lock = "yq . ${lock} > ${lockJson}";
}
