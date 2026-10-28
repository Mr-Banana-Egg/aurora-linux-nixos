{
  lib,
  stdenv,
  patchelf,
  pkg-config,
  fetchFromGitHub,
  aurora-kernel,
}:

stdenv.mkDerivation rec {
  pname = "userpages";
  version = "0.1";

  src = aurora-kernel;
  sourceRoot = "source/tools/aurora-userpages";

  installPhase = ''
    runHook preInstall
    install -Dm755 -t $out/bin userpages
    runHook postInstall
  '';
}
