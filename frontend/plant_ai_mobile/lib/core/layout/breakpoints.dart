import 'package:flutter/foundation.dart';

abstract final class AppBreakpoints {
  static const double mobile = 600;
  static const double desktop = 900;
  static const double maxContentWidth = 1200;

  static bool get isWeb => kIsWeb;

  static bool isMobileWidth(double width) => width < mobile;

  static bool isDesktopWidth(double width) => width >= desktop;

  static double contentWidth(double availableWidth) {
    // Utilise toute la largeur disponible : plus de marges vides sur
    // les grands écrans / fenêtres maximisées.
    return availableWidth;
  }

  // Toujours 4 colonnes : les cartes se redimensionnent (elles ne
  // passent jamais à moins de colonnes), voir MetricsGrid.
  static int metricColumns(double width) => 4;

  // Toujours 2 colonnes : les graphes se redimensionnent eux-mêmes,
  // voir ModelComparisonPanel.
  static int chartColumns(double width) => 2;
}
