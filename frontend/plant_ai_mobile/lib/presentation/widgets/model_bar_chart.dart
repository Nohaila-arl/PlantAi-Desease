import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:plant_ai_mobile/core/app_controller.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';

class ChartDataPoint {
  const ChartDataPoint({required this.name, required this.value});

  final String name;
  final double value;
}

class ModelBarChartWidget extends StatelessWidget {
  const ModelBarChartWidget({
    super.key,
    required this.title,
    required this.data,
  });

  final String title;
  final List<ChartDataPoint> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxValue = data.fold<double>(
      0,
      (max, item) => item.value > max ? item.value : max,
    );
    final chartMax = maxValue <= 0 ? 100.0 : maxValue * 1.2;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Le graphe rétrécit avec la carte (toujours 2 colonnes) sans
        // jamais déborder : hauteur et police suivent la largeur dispo.
        final width = constraints.maxWidth;
        final compact = width < 170;
        final padding = compact ? 12.0 : 16.0;
        final chartHeight = (width * 0.75).clamp(110.0, 190.0);
        final titleFontSize = compact ? 12.0 : 14.0;
        final axisFontSize = compact ? 9.0 : 10.0;

        return Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.textGray300,
                  fontSize: titleFontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: compact ? 8 : 12),
              SizedBox(
                height: chartHeight,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: chartMax,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: compact ? 28 : 36,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(value >= 10 ? 0 : 1),
                              style: TextStyle(
                                color: colors.textMuted,
                                fontSize: axisFontSize,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= data.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                data[index].name,
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: axisFontSize,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: colors.borderSubtle,
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(data.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data[index].value,
                            color: AppColors
                                .chartColors[index % AppColors.chartColors.length],
                            width: compact ? 16 : 28,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ModelComparisonPanel extends StatelessWidget {
  const ModelComparisonPanel({super.key, required this.charts});

  final List<({String title, List<ChartDataPoint> data})> charts;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.modelComparison,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              // Toujours 2 graphes par ligne ; chaque carte se
              // redimensionne elle-même (voir ModelBarChartWidget).
              const spacing = 16.0;
              final cardWidth = (constraints.maxWidth - spacing) / 2;

              final rows = <Widget>[];
              for (var i = 0; i < charts.length; i += 2) {
                final first = charts[i];
                final second = i + 1 < charts.length ? charts[i + 1] : null;

                if (rows.isNotEmpty) rows.add(const SizedBox(height: spacing));

                rows.add(
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: ModelBarChartWidget(
                          title: first.title,
                          data: first.data,
                        ),
                      ),
                      const SizedBox(width: spacing),
                      SizedBox(
                        width: cardWidth,
                        child: second != null
                            ? ModelBarChartWidget(
                                title: second.title,
                                data: second.data,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                );
              }

              return Column(children: rows);
            },
          ),
        ],
      ),
    );
  }
}
