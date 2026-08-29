{ config, pkgs, inputs, ... }: {
  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.default
    inputs.qt6-cava-plugin.packages.${pkgs.system}.default
    pkgs.cava
    pkgs.playerctl
    pkgs.brightnessctl
    pkgs.wireplumber
  ];

  # QML_IMPORT_PATH should include the qt6-cava-plugin's QML module path.
  # The plugin installs to $out/lib/qt6/qml, so we need to add that.
  home.sessionVariables = {
    QML_IMPORT_PATH = "${inputs.qt6-cava-plugin.packages.${pkgs.system}.default}/lib/qt6/qml:\${QML_IMPORT_PATH}";
  };

  home.file.".config/quickshell/persona" = {
    source = ../quickshell/persona;
    recursive = true;
  };
}
