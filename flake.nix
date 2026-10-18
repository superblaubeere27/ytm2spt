{
  description = "ytm2spt - transfer playlists from YouTube Music to Spotify";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          ytm2spt = pkgs.python3Packages.callPackage ./package.nix { src = self; };
        in
        {
          default = ytm2spt;
          inherit ytm2spt;
        });

      # `nix run . -- -yt <playlist> ...` -> CLI
      # `nix run .`                     -> GUI
      apps = forAllSystems (system:
        let
          ytm2spt = self.packages.${system}.ytm2spt;
        in
        {
          default = {
            type = "app";
            program = "${ytm2spt}/bin/ytm2spt";
            meta.description = "Transfer playlists from YouTube Music to Spotify";
          };
          ytm2spt = {
            type = "app";
            program = "${ytm2spt}/bin/ytm2spt";
            meta.description = "Transfer playlists from YouTube Music to Spotify";
          };
          ytmusicapi-oauth = {
            type = "app";
            program = "${ytm2spt}/bin/ytmusicapi-oauth";
            meta.description = "YouTube Music OAuth setup helper (for private playlists)";
          };
        });

      checks = forAllSystems (system: {
        default = self.packages.${system}.ytm2spt;
      });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            packages = [
              self.packages.${system}.ytm2spt
              pkgs.uv
            ];
            shellHook = ''
              echo "ytm2spt dev shell"
              echo "  ytm2spt --help        # CLI"
              echo "  ytm2spt               # GUI"
              echo "  uv sync               # python deps from uv.lock"
            '';
          };
        });

      overlays.default = final: _prev: {
        ytm2spt = final.python3Packages.callPackage ./package.nix { };
      };
    };
}
