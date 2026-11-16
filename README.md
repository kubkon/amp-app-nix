# amp-app-nix

Nix package for the [Amp desktop app](https://ampcode.com/app#linux) on Linux,
repackaged from Amp's official `.deb` (`https://static.ampcode.com/linux/`).

## Use

```nix
{
  inputs.amp-app.url = "github:kubkon/amp-app-nix";
  inputs.amp-app.inputs.nixpkgs.follows = "nixpkgs";

  # ...
  environment.systemPackages = [ amp-app.packages.${pkgs.system}.default ];
}
```

Or with the overlay (needs `nixpkgs.config.allowUnfree = true`):

```nix
nixpkgs.overlays = [ amp-app.overlays.default ];
environment.systemPackages = [ pkgs.amp-desktop ];
```

## Updating

The current version is listed in the apt index:

```console
curl -s https://static.ampcode.com/linux/dists/stable/main/binary-amd64/Packages
```

Bump `version` in `package.nix` and replace both hashes with the SRI form of
each `SHA256` field (`nix hash convert --hash-algo sha256 --to sri <hex>`).

## Notes

- The app's built-in auto-updater targets the `.deb` install and won't work
  here; update by bumping this package.
- The setuid `chrome-sandbox` is removed. Electron falls back to the user
  namespace sandbox, which works on NixOS.
- On Wayland, set `NIXOS_OZONE_WL=1` to run natively instead of via XWayland.
