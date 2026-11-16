{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libGL,
  libnotify,
  libsecret,
  libuuid,
  libxkbcommon,
  nspr,
  nss,
  pango,
  systemd,
  wayland,
  xdg-utils,
  libX11,
  libXcomposite,
  libXdamage,
  libXext,
  libXfixes,
  libXrandr,
  libXScrnSaver,
  libXtst,
  libxcb,
  libxshmfence,
}:

let
  sources = {
    x86_64-linux = {
      arch = "amd64";
      hash = "sha256-icC9T/Ho+A4ypBZNe8rxdPy2fu5nFTLv+xWI5ErgbaY=";
    };
    aarch64-linux = {
      arch = "arm64";
      hash = "sha256-itD+q7kloqsLtHvYrNR5OivQUjwfJUPBzeqbkDXJM1g=";
    };
  };

  runtimeLibs = [
    libGL
    libnotify
    libsecret
    libuuid
    libXScrnSaver
    libXtst
    systemd
    wayland
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "amp-desktop";
  version = "0.1.29913241";

  src =
    let
      s = sources.${stdenv.hostPlatform.system};
    in
    fetchurl {
      url = "https://static.ampcode.com/linux/${finalAttrs.version}/amp-desktop-${finalAttrs.version}-${s.arch}.deb";
      inherit (s) hash;
    };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libxkbcommon
    nspr
    nss
    pango
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxshmfence
  ]
  ++ runtimeLibs;

  runtimeDependencies = runtimeLibs;

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -r opt $out/
    cp -r usr/share/icons $out/share/

    # The deb ships a setuid chrome-sandbox; Nix can't install setuid binaries.
    rm $out/opt/amp/chrome-sandbox

    install -Dm644 usr/share/applications/amp-desktop.desktop \
      $out/share/applications/amp-desktop.desktop
    substituteInPlace $out/share/applications/amp-desktop.desktop \
      --replace-fail /opt/amp/amp-desktop amp-desktop

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/opt/amp/amp-desktop $out/bin/amp-desktop \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibs} \
      --prefix PATH : ${lib.makeBinPath [ xdg-utils ]} \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';

  meta = {
    description = "Desktop app for Amp, the frontier coding agent";
    homepage = "https://ampcode.com/app";
    downloadPage = "https://ampcode.com/docs/apps/linux";
    license = lib.licenses.unfree;
    mainProgram = "amp-desktop";
    platforms = builtins.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
