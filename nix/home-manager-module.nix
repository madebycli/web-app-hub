{ config, lib, pkgs, defaultPackage, ... }:
let
  cfg = config.programs.web-app-hub;
in
{
  options.programs.web-app-hub = {
    enable = lib.mkEnableOption "Web App Hub";
    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      defaultText = lib.literalExpression "inputs.web-app-hub.packages.${pkgs.system}.web-app-hub";
      description = "The Web App Hub package to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
