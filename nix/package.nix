{
  lib,
  rustPlatform,
  pkg-config,
  wrapGAppsHook4,
  gtk4,
  libadwaita,
}:

let
  cargoToml = builtins.fromTOML (builtins.readFile ../Cargo.toml);
in
rustPlatform.buildRustPackage {
  pname = "web-app-hub";
  version = cargoToml.workspace.package.version;

  src = lib.cleanSource ../.;

  cargoLock.lockFile = ../Cargo.lock;
  cargoBuildFlags = [ "-p" "app" ];

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  # The upstream build script writes generated desktop/icon files into the
  # current user's XDG directories. Redirect those build-time writes into the
  # Nix sandbox; the final immutable desktop assets are installed below.
  preBuild = ''
    export HOME="$TMPDIR/home"
    export XDG_DATA_HOME="$TMPDIR/xdg-data"
    export XDG_CONFIG_HOME="$TMPDIR/xdg-config"
    export XDG_CACHE_HOME="$TMPDIR/xdg-cache"
    mkdir -p "$HOME" "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"
  '';

  doCheck = false;

  postInstall = ''
    install -Dm644 assets/desktop/org.pvermeer.WebAppHub.desktop \
      "$out/share/applications/org.pvermeer.WebAppHub.desktop"
    install -Dm644 assets/desktop/org.pvermeer.WebAppHub.png \
      "$out/share/icons/hicolor/256x256/apps/org.pvermeer.WebAppHub.png"
    install -Dm644 assets/desktop/org.pvermeer.WebAppHub.metainfo.xml \
      "$out/share/metainfo/org.pvermeer.WebAppHub.metainfo.xml"
  '';

  meta = {
    description = cargoToml.workspace.package.description;
    homepage = "https://github.com/madebycli/web-app-hub";
    license = lib.licenses.gpl3Only;
    mainProgram = "web-app-hub";
    platforms = lib.platforms.linux;
  };
}
