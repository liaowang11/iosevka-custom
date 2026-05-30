{
  stdenvNoCC,
  lib,
  fetchurl,
  unzip,
  version,
  variantHashes,
  variant ? "Custom",
  owner ? "liaowang11",
  repo ? "iosevka-custom",
}:

let
  archiveName = if variant == "Custom" then "iosevka-custom-ttf" else "iosevka-custom-${lib.toLower variant}-ttf";
  sha256 = variantHashes.${variant} or lib.fakeSha256;
in
stdenvNoCC.mkDerivation {
  pname = "iosevka-custom-bin";
  inherit version;

  src = fetchurl {
    url = "https://github.com/${owner}/${repo}/releases/download/v${version}/${archiveName}-${version}.zip";
    inherit sha256;
  };

  nativeBuildInputs = [ unzip ];

  dontConfigure = true;
  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    fontdir="$out/share/fonts/truetype"
    install -d "$fontdir"
    unzip -d "$fontdir" "$src"
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/${owner}/${repo}";
    downloadPage = "https://github.com/${owner}/${repo}/releases";
    description = "Prebuilt Iosevka Custom font package from GitHub Releases";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
