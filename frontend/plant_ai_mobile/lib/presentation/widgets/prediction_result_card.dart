import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:plant_ai_mobile/core/app_controller.dart';
import 'package:plant_ai_mobile/core/layout/breakpoints.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';
import 'package:plant_ai_mobile/data/models/prediction_result.dart';

class PredictionResultCard extends StatelessWidget {
  const PredictionResultCard({
    super.key,
    required this.imageBytes,
    required this.result,
  });

  final Uint8List? imageBytes;
  final PredictionResult? result;

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Row(
      children: [
        const Icon(LucideIcons.leaf, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          l10n.predictionResult,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, {double? height}) {
    final colors = context.colors;
    final imageHeight = height ?? 220.0;

    if (imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          imageBytes!,
          width: double.infinity,
          height: imageHeight,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: imageHeight,
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderDashed),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.leaf, color: colors.borderDashed, size: 40),
          const SizedBox(height: 8),
          Text(
            context.l10n.waitingForImage,
            style: TextStyle(color: colors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String body,
    String? caption,
  }) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              color: colors.textGray300,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          if (caption != null && caption.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              caption,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultDetails(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    if (result == null) {
      return Text(
        l10n.noDetectionYet,
        style: TextStyle(color: colors.textMuted, fontSize: 14),
      );
    }

    final isHealthy = result!.status.toLowerCase().contains('healthy') ||
        result!.status.toLowerCase().contains('sain');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                result!.disease,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isHealthy ? colors.healthyBg : colors.infectedBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.statusLabel(result!.status),
                style: TextStyle(
                  color: isHealthy
                      ? AppColors.healthyText
                      : AppColors.infectedText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          l10n.confidenceScore,
          style: TextStyle(color: colors.textGray400, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          '${result!.confidence.toStringAsFixed(1)}%',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: result!.confidence / 100,
            minHeight: 8,
            backgroundColor: colors.progressTrack,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }

  // Bloc traitement en pleine largeur, affiché juste sous les
  // résultats de la détection (au lieu d'être serré dans la colonne
  // à côté de l'image sur desktop).
  Widget _buildTreatmentSection(BuildContext context) {
    final l10n = context.l10n;

    if (result == null) return const SizedBox.shrink();

    final treatmentText =
        result!.treatment.isNotEmpty ? result!.treatment : l10n.noTreatment;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: _buildInfoBox(
        context: context,
        icon: LucideIcons.heartPulse,
        title: l10n.treatment,
        body: treatmentText,
        caption: result!.treatmentSource,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = AppBreakpoints.isDesktopWidth(constraints.maxWidth);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildImagePreview(context, height: 280),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 6,
                      child: _buildResultDetails(context),
                    ),
                  ],
                )
              else ...[
                _buildImagePreview(context),
                const SizedBox(height: 20),
                _buildResultDetails(context),
              ],
              // Placée sous le bloc image + résultats, sur toute la
              // largeur, quel que soit l'écran.
              _buildTreatmentSection(context),
            ],
          );
        },
      ),
    );
  }
}
