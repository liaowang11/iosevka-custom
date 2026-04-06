{
  description = "Standalone Iosevka Custom package";

  nixConfig = {
    extra-substituters = [ "https://iosevka-wliao.cachix.org" ];
    extra-trusted-public-keys = [
      "iosevka-wliao.cachix.org-1:IJ+8jBJgx0SkMs2IA7V7XME5tdcVmpQSoL2JH1Bcy9E="
    ];
  };

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/36a601196c4ebf49e035270e10b2d103fe39076b";

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = lib.genAttrs supportedSystems;

      mkIosevkaCustom =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
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
    in
    {
      packages = forAllSystems (system: {
        default = mkIosevkaCustom system;
        iosevka-custom = mkIosevkaCustom system;
      });

      checks = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default =
            assert self.packages.${system}.default.pname == "IosevkaCustom";
            pkgs.runCommand "iosevka-custom-eval-check" { } "touch $out";
        }
      );
    };
}
