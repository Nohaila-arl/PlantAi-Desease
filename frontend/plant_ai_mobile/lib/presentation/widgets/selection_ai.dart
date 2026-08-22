import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:plant_ai_mobile/core/app_controller.dart';
import 'package:plant_ai_mobile/core/constants/api_constants.dart';
import 'package:plant_ai_mobile/core/constants/model_constants.dart';
import 'package:plant_ai_mobile/core/layout/breakpoints.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';
import 'package:plant_ai_mobile/data/models/detection_history_item.dart';
import 'package:plant_ai_mobile/data/models/prediction_result.dart';
import 'package:plant_ai_mobile/data/services/plant_api_service.dart';

class SelectionAI extends StatefulWidget {
  const SelectionAI({
    super.key,
    required this.onImageSelected,
    required this.onResult,
    required this.onDetectionAdded,
  });

  final ValueChanged<Uint8List?> onImageSelected;
  final ValueChanged<PredictionResult?> onResult;
  final ValueChanged<DetectionHistoryItem> onDetectionAdded;

  @override
  State<SelectionAI> createState() => _SelectionAIState();
}

class _SelectionAIState extends State<SelectionAI> {
  final _apiService = PlantApiService();
  final _picker = ImagePicker();

  String _selectedModel = 'MobileNet';
  Uint8List? _imageBytes;
  String? _fileName;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    if (bytes.length > ApiConstants.maxImageSizeBytes) {
      if (mounted) {
        _showMessage(context.l10n.imageTooLarge);
      }
      return;
    }

    setState(() {
      _imageBytes = bytes;
      _fileName = picked.name;
    });
    widget.onImageSelected(bytes);
  }

  Future<void> _handleDetection() async {
    if (_imageBytes == null) {
      _showMessage(context.l10n.chooseImageFirst);
      return;
    }

    final modelInfo = ModelConstants.getModelByName(_selectedModel);

    setState(() => _loading = true);

    try {
      final result = await _apiService.predict(
        imageBytes: _imageBytes!,
        fileName: _fileName ?? 'leaf.jpg',
        modelApiName: modelInfo.apiName,
        modelDisplayName: modelInfo.name,
      );

      widget.onResult(result);

      widget.onDetectionAdded(
        DetectionHistoryItem(
          id: DateTime.now().millisecondsSinceEpoch,
          imageBytes: _imageBytes!,
          detection: result.disease,
          accuracy: result.confidence,
          model: modelInfo.name,
          status: result.status,
          time: context.l10n.justNow,
          modelColor: modelInfo.color.toARGB32(),
          responseTime: result.responseTime,
          cpu: result.cpu,
          ram: result.ram,
        ),
      );
    } catch (e) {
      _showMessage(context.l10n.detectionFailed);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.cardBackground,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border.all(color: colors.borderDefault),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = AppBreakpoints.isDesktopWidth(constraints.maxWidth);

          if (isDesktop) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 42,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: _buildChooseModelSection(desktop: true),
                    ),
                  ),
                  VerticalDivider(
                    color: colors.borderDefault,
                    width: 1,
                    thickness: 1,
                  ),
                  Expanded(
                    flex: 33,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildUploadSection(),
                    ),
                  ),
                  VerticalDivider(
                    color: colors.borderDefault,
                    width: 1,
                    thickness: 1,
                  ),
                  Expanded(
                    flex: 25,
                    child: _buildDetectSection(compact: true),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChooseModelSection(),
              const SizedBox(height: 24),
              Divider(color: colors.borderDefault, height: 1),
              const SizedBox(height: 24),
              _buildUploadSection(),
              const SizedBox(height: 24),
              Divider(color: colors.borderDefault, height: 1),
              const SizedBox(height: 24),
              _buildDetectSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChooseModelSection({bool desktop = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context.l10n.chooseModel),
        const SizedBox(height: 16),
        if (desktop)
          Row(
            children: ModelConstants.models.map((model) {
              final isSelected = _selectedModel == model.name;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _ModelCard(
                    model: model,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedModel = model.name),
                    expand: true,
                  ),
                ),
              );
            }).toList(),
          )
        else
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ModelConstants.models.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final model = ModelConstants.models[index];
                final isSelected = _selectedModel == model.name;
                return _ModelCard(
                  model: model,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedModel = model.name),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUploadSection() {
    final colors = context.colors;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.uploadLeaf),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.borderDashed),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.upload, color: AppColors.primary, size: 25),
              const SizedBox(height: 8),
              Text(
                l10n.dragDrop,
                style: TextStyle(color: colors.textGray400, fontSize: 10),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.chooseFile,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.fileHint,
                style: TextStyle(color: colors.textMuted, fontSize: 8),
              ),
            ],
          ),
        ),
        if (_fileName != null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.selectedFile(_fileName!),
            style: TextStyle(color: colors.textGray400, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildDetectSection({bool compact = false}) {
    final colors = context.colors;
    final l10n = context.l10n;

    final button = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.detectGradientStart,
                AppColors.detectGradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _loading ? null : _handleDetection,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 24 : 32,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_loading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(LucideIcons.search, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _loading ? l10n.analyzing : l10n.detectDisease,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _loading ? l10n.analysisInProgress : l10n.startAnalysis,
          style: TextStyle(color: colors.textGray400, fontSize: 10),
        ),
      ],
    );

    if (compact) {
      return Center(child: button);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.detectStep),
        const SizedBox(height: 16),
        Center(child: button),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({
    required this.model,
    required this.isSelected,
    required this.onTap,
    this.expand = false,
  });

  final ModelInfo model;
  final bool isSelected;
  final VoidCallback onTap;
  final bool expand;

  Color _modelBackground(AppColors colors) {
    switch (model.name) {
      case 'ResNet':
        return colors.resnetBg;
      case 'YOLO':
        return colors.yoloBg;
      default:
        return colors.mobilenetBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: expand ? null : 140,
        height: 130,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(
            color: isSelected ? model.color : colors.borderSubtle,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: model.color.withValues(alpha: 0.35),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _modelBackground(colors),
                shape: BoxShape.circle,
              ),
              child: Icon(model.icon, color: model.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              model.name,
              style: TextStyle(
                color: model.name == 'MobileNet' ? model.color : colors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.modelSubtitle(model.name),
              style: TextStyle(
                color: colors.textGray400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
