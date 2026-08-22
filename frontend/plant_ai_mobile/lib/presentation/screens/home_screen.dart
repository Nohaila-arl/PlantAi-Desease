import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:plant_ai_mobile/core/app_controller.dart';
import 'package:plant_ai_mobile/core/constants/model_constants.dart';
import 'package:plant_ai_mobile/core/layout/breakpoints.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';
import 'package:plant_ai_mobile/data/models/detection_history_item.dart';
import 'package:plant_ai_mobile/data/models/prediction_result.dart';
import 'package:plant_ai_mobile/presentation/widgets/app_header.dart';
import 'package:plant_ai_mobile/presentation/widgets/hero_section.dart';
import 'package:plant_ai_mobile/presentation/widgets/metric_card.dart';
import 'package:plant_ai_mobile/presentation/widgets/model_bar_chart.dart';
import 'package:plant_ai_mobile/presentation/widgets/prediction_result_card.dart';
import 'package:plant_ai_mobile/presentation/widgets/recent_detection_tile.dart';
import 'package:plant_ai_mobile/presentation/widgets/selection_ai.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? _selectedImageBytes;
  PredictionResult? _lastResult;
  final List<DetectionHistoryItem> _detections = [];

  double _calculateAverage(String modelName, String field) {
    final filtered = _detections.where((d) => d.model == modelName).toList();
    if (filtered.isEmpty) return 0;

    double sum = 0;
    for (final detection in filtered) {
      switch (field) {
        case 'accuracy':
          sum += detection.accuracy;
        case 'responseTime':
          sum += detection.responseTime;
        case 'cpu':
          sum += detection.cpu;
        case 'ram':
          sum += detection.ram;
      }
    }
    return sum / filtered.length;
  }

  List<({String title, List<ChartDataPoint> data})> _comparisonCharts() {
    final l10n = context.l10n;
    return [
      (
        title: l10n.chartAccuracy,
        data: [
          ChartDataPoint(name: 'MobileNet', value: _calculateAverage('MobileNet', 'accuracy')),
          ChartDataPoint(name: 'ResNet', value: _calculateAverage('ResNet', 'accuracy')),
          ChartDataPoint(name: 'YOLO', value: _calculateAverage('YOLO', 'accuracy')),
        ],
      ),
      (
        title: l10n.chartResponseTime,
        data: [
          ChartDataPoint(name: 'MobileNet', value: _calculateAverage('MobileNet', 'responseTime')),
          ChartDataPoint(name: 'ResNet', value: _calculateAverage('ResNet', 'responseTime')),
          ChartDataPoint(name: 'YOLO', value: _calculateAverage('YOLO', 'responseTime')),
        ],
      ),
      (
        title: l10n.chartCpu,
        data: [
          ChartDataPoint(name: 'MobileNet', value: _calculateAverage('MobileNet', 'cpu')),
          ChartDataPoint(name: 'ResNet', value: _calculateAverage('ResNet', 'cpu')),
          ChartDataPoint(name: 'YOLO', value: _calculateAverage('YOLO', 'cpu')),
        ],
      ),
      (
        title: l10n.chartRam,
        data: [
          ChartDataPoint(name: 'MobileNet', value: _calculateAverage('MobileNet', 'ram')),
          ChartDataPoint(name: 'ResNet', value: _calculateAverage('ResNet', 'ram')),
          ChartDataPoint(name: 'YOLO', value: _calculateAverage('YOLO', 'ram')),
        ],
      ),
    ];
  }

  List<MetricData> _metrics() {
    final l10n = context.l10n;
    final modelName = _lastResult?.model ?? 'MobileNet';
    final acc = ModelConstants.modelAccuracy[modelName]!;

    return [
      MetricData(
        labelIcon: LucideIcons.clock,
        label: l10n.responseTime,
        valueIcon: LucideIcons.zap,
        value: _lastResult != null ? '${_lastResult!.responseTime.toStringAsFixed(2)} s' : '—',
        color: AppColors.primary,
      ),
      MetricData(
        labelIcon: LucideIcons.cpu,
        label: l10n.cpuUsage,
        valueIcon: LucideIcons.cpu,
        value: _lastResult != null ? '${_lastResult!.cpu.toStringAsFixed(1)}%' : '—',
        color: AppColors.resnet,
      ),
      MetricData(
        labelIcon: LucideIcons.memoryStick,
        label: l10n.ramUsage,
        valueIcon: LucideIcons.memoryStick,
        value: _lastResult != null ? '${_lastResult!.ram.toStringAsFixed(1)}%' : '—',
        color: AppColors.yolo,
      ),
      MetricData(
        labelIcon: LucideIcons.database,
        label: l10n.modelSize,
        valueIcon: LucideIcons.database,
        value: _lastResult != null ? '${_lastResult!.modelSize.toStringAsFixed(1)} MB' : '—',
        color: AppColors.metricCyan,
      ),
      MetricData(
        labelIcon: LucideIcons.target,
        label: l10n.accuracy,
        valueIcon: LucideIcons.checkCircle,
        value: acc['accuracy']!,
        color: AppColors.primary,
      ),
      MetricData(
        labelIcon: LucideIcons.crosshair,
        label: l10n.precision,
        valueIcon: LucideIcons.target,
        value: acc['precision']!,
        color: AppColors.metricGreen,
      ),
      MetricData(
        labelIcon: LucideIcons.crosshair,
        label: l10n.recall,
        valueIcon: LucideIcons.target,
        value: acc['recall']!,
        color: AppColors.metricBlue,
      ),
      MetricData(
        labelIcon: LucideIcons.star,
        label: l10n.f1Score,
        valueIcon: LucideIcons.star,
        value: acc['f1']!,
        color: AppColors.metricYellow,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = AppBreakpoints.contentWidth(constraints.maxWidth);

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppHeader(),
                    const HeroSection(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectionAI(
                        onImageSelected: (bytes) => setState(() => _selectedImageBytes = bytes),
                        onResult: (result) => setState(() => _lastResult = result),
                        onDetectionAdded: (detection) => setState(() {
                          _detections.insert(0, detection);
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: PredictionResultCard(
                        imageBytes: _selectedImageBytes,
                        result: _lastResult,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: MetricsGrid(metrics: _metrics()),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ModelComparisonPanel(charts: _comparisonCharts()),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      child: RecentDetectionsPanel(detections: _detections),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
