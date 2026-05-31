{
  description = "Standalone Iosevka Custom package";

  nixConfig = {
    extra-substituters = [ "https://iosevka-wliao.cachix.org" ];
    extra-trusted-public-keys = [
      "iosevka-wliao.cachix.org-1:IJ+8jBJgx0SkMs2IA7V7XME5tdcVmpQSoL2JH1Bcy9E="
    ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      allSystems = lib.platforms.all;
      sourceSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = lib.genAttrs allSystems;
      forSourceSystems = lib.genAttrs sourceSystems;
      variantHashes = import ./variants.nix;

      mkPkgs = system: import nixpkgs { inherit system; };

      mkIosevkaCustom =
        system:
        let
          pkgs = mkPkgs system;
        in
        pkgs.iosevka.override {
          privateBuildPlan = {
            family = "Iosevka Custom";
            spacing = "fontconfig-mono";
            serifs = "sans";
            no-cv-ss = false;
            exportGlyphNames = true;
            variants = {
              inherits = "ss14";
              design = {
                brace = "straight";
                ampersand = "upper-open";
                lig-equal-chain = "with-notch";
              };
            };
            ligations = {
              inherits = "dlig";
            };
          };
          set = "Custom";
        };

      mkIosevkaCustomBin =
        system:
        let
          pkgs = mkPkgs system;
        in
        pkgs.callPackage ./iosevka-custom-bin.nix {
          inherit variantHashes;
          version = pkgs.iosevka.version;
        };
    in
    {
      packages = forAllSystems (system: {
        iosevka-custom-bin = mkIosevkaCustomBin system;
      }) // forSourceSystems (system: {
        default = mkIosevkaCustom system;
        iosevka-custom = mkIosevkaCustom system;
        iosevka-custom-bin = mkIosevkaCustomBin system;
      });

      checks = forSourceSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default =
            assert self.packages.${system}.default.pname == "IosevkaCustom";
            pkgs.runCommand "iosevka-custom-eval-check" { } "touch $out";
          update-workflow =
            assert import ./tests/update-workflow.nix;
            pkgs.runCommand "iosevka-custom-update-workflow-check" { } "touch $out";
        }
      );
    };
}
