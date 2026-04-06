# iosevka-custom

This repository builds the `Iosevka Custom` font package and publishes successful builds to the `iosevka-wliao` Cachix cache.

## Outputs

- `packages.aarch64-darwin.default`
- `packages.x86_64-linux.default`

## GitHub Actions

The workflow in `.github/workflows/build.yml` builds:

- `aarch64-darwin` on `macos-15`
- `x86_64-linux` on `ubuntu-24.04`

Pull requests build without pushing to Cachix. Pushes to `main` and manual runs push successful builds to `iosevka-wliao`.

The scheduled workflow in `.github/workflows/update-nixpkgs.yml` runs every Friday at `03:00 UTC`, updates the `nixpkgs` lock entry, commits `flake.lock` when it changes, and rebuilds the package on both supported systems.

## Required Secret

Add this repository secret before enabling cache pushes:

- `CACHIX_AUTH_TOKEN`: write token for the `iosevka-wliao` cache

## Local Usage

```bash
nix build .#default
```

To consume this package from another flake, add the repo as an input and use `inputs.iosevka-custom.packages.${system}.default`.
