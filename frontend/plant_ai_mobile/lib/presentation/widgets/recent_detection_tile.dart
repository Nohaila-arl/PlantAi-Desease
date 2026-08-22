import 'package:flutter/material.dart';
import 'package:plant_ai_mobile/core/app_controller.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';
import 'package:plant_ai_mobile/data/models/detection_history_item.dart';

class RecentDetectionTile extends StatelessWidget {
  const RecentDetectionTile({super.key, required this.detection});

  final DetectionHistoryItem detection;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final modelColor = Color(detection.modelColor);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              detection.imageBytes,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detection.detection,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  detection.model,
                  style: TextStyle(
                    color: colors.textGray400,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: modelColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              detection.model,
              style: TextStyle(
                color: modelColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${detection.accuracy.toStringAsFixed(0)}%',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentDetectionsPanel extends StatelessWidget {
  const RecentDetectionsPanel({super.key, required this.detections});

  final List<DetectionHistoryItem> detections;

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
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.recentDetections,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (detections.isEmpty)
            Text(
              l10n.noDetections,
              style: TextStyle(color: colors.textMuted, fontSize: 14),
            )
          else
            ...detections.map(
              (detection) => RecentDetectionTile(detection: detection),
            ),
        ],
      ),
    );
  }
}
