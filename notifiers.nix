{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  systemdMinimal,
  jq,
  wayland,
  libnotify,
  pulseaudio,
  udev
}:

stdenv.mkDerivation {
  name = "desktop-notifiers";
  src = fetchFromGitHub {
    owner = "Ongy";
    repo = "desktop-notifiers";
    rev = "75e2832b7c4e908727caa0c75400d91f280f2159";
    hash = "sha256-PrFfjYVk/QzVav9K4irCcelhbJYnrRtmswC+egwAQiw=";
  };
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];
  buildInputs = [
    systemdMinimal
    wayland
    pulseaudio
    udev
    libnotify
  ];

  meta = {
    description = "Small desktop environment notifier dameons for config changes";
    platforms = lib.platforms.linux;
  };
}
