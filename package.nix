{ lib
, stdenv
, buildPythonApplication
, hatchling
, pythonRelaxDepsHook
, pyside6
, spotipy
, thefuzz
, ytmusicapi
, qt6
# Defaults to this checkout, so `nix build` works straight from the repo.
, src ? lib.cleanSource ./.
}:

buildPythonApplication {
  pname = "ytm2spt";
  version = "1.1.2";
  pyproject = true;

  inherit src;

  build-system = [
    hatchling
  ];

  nativeBuildInputs = [
    pythonRelaxDepsHook
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    qt6.wrapQtAppsHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    qt6.qtbase
    qt6.qtwayland
  ];

  # pyproject.toml pins ytmusicapi==1.10.3; nixpkgs ships a newer compatible
  # release, so relax the pin instead of vendoring an old version.
  pythonRelaxDeps = [
    "ytmusicapi"
  ];

  dependencies = [
    pyside6
    spotipy
    thefuzz
    ytmusicapi
  ];

  # Qt apps need the Qt plugin env vars, which wrapQtAppsHook normally bakes
  # into a dedicated wrapper. buildPythonApplication generates its own
  # `bin/ytm2spt` wrapper, so forward the Qt wrapper args into it instead of
  # letting the hook create a second wrapper.
  dontWrapQtApps = true;
  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  doCheck = false;

  meta = {
    description = "Transfer playlists from YouTube Music to Spotify";
    homepage = "https://github.com/superblaubeere27/ytm2spt";
    license = lib.licenses.gpl3Only;
    mainProgram = "ytm2spt";
    platforms = lib.platforms.unix;
  };
}
