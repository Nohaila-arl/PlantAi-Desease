import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:plant_ai_mobile/core/app_controller.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';

class MetricCardWidget extends StatelessWidget {
  const MetricCardWidget({
    super.key,
    required this.labelIcon,
    required this.label,
    required this.valueIcon,
    required this.value,
    required this.color,
  });

  final IconData labelIcon;
  final String label;
  final IconData valueIcon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        // La carte se redimensionne toute seule selon la place dispo
        // (utilisé quand la grille garde toujours 4 colonnes).
        final cardWidth = constraints.maxWidth;
        final compact = cardWidth < 110;
        final ultraCompact = cardWidth < 82;

        final labelIconSize = ultraCompact ? 13.0 : (compact ? 15.0 : 18.0);
        final valueIconSize = ultraCompact ? 15.0 : (compact ? 18.0 : 22.0);
        final labelFontSize = ultraCompact ? 10.0 : (compact ? 11.5 : 13.0);
        final valueFontSize = ultraCompact ? 13.0 : (compact ? 16.0 : 20.0);
        final padding = ultraCompact ? 8.0 : (compact ? 12.0 : 16.0);
        final gap = ultraCompact ? 4.0 : (compact ? 8.0 : 12.0);
        final iconGap = ultraCompact ? 4.0 : 8.0;

        return Container(
          constraints: BoxConstraints(minHeight: ultraCompact ? 82 : 92),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.borderSubtle),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(labelIcon, size: labelIconSize, color: color),
                  SizedBox(width: iconGap),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: gap),
              Row(
                children: [
                  Icon(valueIcon, size: valueIconSize, color: color),
                  SizedBox(width: iconGap),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class MetricsGrid extends StatelessWidget {
  const MetricsGrid({super.key, required this.metrics});

  final List<MetricData> metrics;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChart2, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.performanceMetrics,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              const crossAxisCount = 4;
              const spacing = 12.0;

              // Largeur réelle d'une carte une fois les 4 colonnes posées.
              final cardWidth =
                  (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                      crossAxisCount;
              // Hauteur fixe (et non un ratio) pour ne jamais dépendre
              // d'un calcul approximatif : marge confortable pour que le
              // texte sur 2 lignes ne déborde jamais, quelle que soit la
              // largeur de la carte.
              final rowHeight = cardWidth < 82
                  ? 118.0
                  : cardWidth < 110
                      ? 128.0
                      : 132.0;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  mainAxisExtent: rowHeight,
                ),
                itemCount: metrics.length,
                itemBuilder: (context, index) {
                  final metric = metrics[index];
                  return MetricCardWidget(
                    labelIcon: metric.labelIcon,
                    label: metric.label,
                    valueIcon: metric.valueIcon,
                    value: metric.value,
                    color: metric.color,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class MetricData {
  const MetricData({
    required this.labelIcon,
    required this.label,
    required this.valueIcon,
    required this.value,
    required this.color,
  });

  final IconData labelIcon;
  final String label;
  final IconData valueIcon;
  final String value;
  final Color color;
}
