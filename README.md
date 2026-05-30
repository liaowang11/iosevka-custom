# iosevka-custom

This repository builds the `Iosevka Custom` font package, publishes successful source builds to the `iosevka-wliao` Cachix cache, and publishes zipped TTF release assets for the cross-platform `iosevka-custom-bin` package.

## Outputs

Source-built package outputs:
- `packages.aarch64-darwin.default`
- `packages.x86_64-linux.default`

Release-backed binary package outputs:
- `packages.<system>.iosevka-custom-bin` for all nixpkgs platforms

The `iosevka-custom-bin` package downloads a GitHub release asset from this repo and unpacks the prebuilt TTF files into `$out/share/fonts/truetype`.

## GitHub Actions

The workflow in `.github/workflows/build.yml` builds on `x86_64-linux`, uploads a zipped TTF artifact, and publishes it as a GitHub Release asset tagged by the package version.

The scheduled workflow in `.github/workflows/update-nixpkgs.yml` runs every Friday at `03:00 UTC`, updates the `nixpkgs` lock entry, commits `flake.lock` when it changes, rebuilds the Linux package, and refreshes the GitHub Release asset.

## Required Secret

Add this repository secret before enabling cache pushes:

- `CACHIX_AUTH_TOKEN`: write token for the `iosevka-wliao` cache

## Local Usage

Build the source package:

```bash
nix build .#default
```

Consume the release-backed binary package:

```bash
nix build .#iosevka-custom-bin
```

To consume from another flake, add the repo as an input and use either:

- `inputs.iosevka-custom.packages.${system}.default`
- `inputs.iosevka-custom.packages.${system}.iosevka-custom-bin`

## Maintaining release hashes

`variants.nix` stores the sha256 hashes for published release archives. `iosevka-custom-bin` falls back to `lib.fakeSha256` until the first release exists, so the initial build/release workflow can bootstrap itself. After the first GitHub release asset is published, run a local `nix build .#iosevka-custom-bin`, copy the expected hash from the fetch error, and update `variants.nix` so future builds stay fully reproducible.
