{ config, pkgs, inputs, ... }: {
  home.packages = [
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.qt6-cava-plugin.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.cava
    pkgs.playerctl
    pkgs.brightnessctl
    pkgs.wireplumber
    pkgs.qt6.qtmultimedia # QtMultimedia QML module used by Layers/Resume.qml (p3r intro video)
  ];

  # QML_IMPORT_PATH should include the qt6-cava-plugin's QML module path.
  # The plugin installs to $out/lib/qt6/qml, so we need to add that.
  home.sessionVariables = {
    QML_IMPORT_PATH = "${inputs.qt6-cava-plugin.packages.${pkgs.stdenv.hostPlatform.system}.default}/lib/qt6/qml:${pkgs.qt6.qtmultimedia}/lib/qt-6/qml:\${QML_IMPORT_PATH}";
  };

  home.file.".config/quickshell/persona" = {
    source = ../quickshell/persona;
    recursive = true;
  };
}
