{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cargo,
  cmake,
  ninja,
  pkg-config,
  rustPlatform,
  rustc,
  curl,
  freetype,
  libGLU,
  libnotify,
  libogg,
  libX11,
  opusfile,
  pcre,
  python3,
  SDL2,
  sqlite,
  wavpack,
  ffmpeg,
  x264,
  vulkan-headers,
  vulkan-loader,
  glslang,
  spirv-tools,
  gtest,
  Carbon,
  Cocoa,
  OpenGL,
  Security,
  buildClient ? true,
}:

stdenv.mkDerivation rec {
  pname = "TaterClient-ddnet";
  version = "8.5.4";

  src = fetchFromGitHub {
    owner = "sjrc6";
    repo = pname;
    rev = version;
    hash = "sha256-AYKCdnTPfIWbEBBMGQeJ1UO8VybyehJ3SDmtrcAiqfI=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    name = "${pname}-${version}";
    inherit src;
    hash = "sha256-zym/OOLhfAFl7UqQSZWNc60NXJXd+9eVmvcW3qQAnb0=";
  };

  nativeBuildInputs = [
    pkgs.ddnet.nativeBuildInputs
  ];

  nativeCheckInputs = [ gtest ];

  buildInputs = [
    pkgs.ddnet.buildInputs  # the sole purpose for this is to remove boilerplate
  ];

  postPatch = ''
    substituteInPlace src/engine/shared/storage.cpp \
      --replace /usr/ $out/
  '';

  cmakeFlags = [
    "-DAUTOUPDATE=OFF"
    "-DCLIENT=${if buildClient then "ON" else "OFF"}"
  ];

  # Tests loop forever on Darwin for some reason
  doCheck = !stdenv.hostPlatform.isDarwin;
  checkTarget = "run_tests";

  postInstall = lib.optionalString (!buildClient) ''
    # DDNet's CMakeLists.txt automatically installs .desktop
    # shortcuts and icons for the client, even if the client
    # is not supposed to be built
    rm -rf $out/share/applications
    rm -rf $out/share/icons
    rm -rf $out/share/metainfo
  '';

  meta = with lib; {
    description = "Taters custom ddnet client with some small modifications";
    longDescription = ''
      DDraceNetwork (DDNet) is an actively maintained version of DDRace,
      a Teeworlds modification with a unique cooperative gameplay.
      Help each other play through custom maps with up to 64 players,
      compete against the best in international tournaments,
      design your own maps, or run your own server.
    '';
    homepage = "https://ddnet.org";
    license = licenses.asl20;
    maintainers = with maintainers; [ melon ];
    mainProgram = "DDNet";
  };
}
