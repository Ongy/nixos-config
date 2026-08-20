{
  lib,
  alsa-lib,
  buildGoModule,
  fetchFromGitHub,
  ffmpeg,
  libogg,
  opus,
  opusfile,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "sendspin-go";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "Sendspin";
    repo = "sendspin-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T0lOczyUi6YvlMqbrdAnWpFmTqJ7fVKm5yOeZueLwkg=";
  };

  __structuredAttrs = true;

  vendorHash = "sha256-4V/EQ07jMKiEHPYm4s/U8zafD/IEoRjdYKHHmuHtD1Y=";

  nativeBuildInputs = [ pkg-config ];
  patches = [
    ./sendspin.patch
  ];

  buildInputs = [
    alsa-lib
    libogg
    opus
    opusfile
    ffmpeg
  ];

  env.CGO_LDFLAGS = "-lm";

  ldflags = [ "-s" ];

  preCheck = ''
    # Tests require network features that are not available in the sandbox
    substituteInPlace pkg/discovery/mdns_test.go \
      --replace-fail "TestGetLocalIPs" "Skip_TestGetLocalIPs"
  '';

  meta = {
    description = "Sendspin server and client";
    homepage = "https://github.com/Sendspin/sendspin-go";
    changelog = "https://github.com/Sendspin/sendspin-go/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "sendspin-go";
  };
})
