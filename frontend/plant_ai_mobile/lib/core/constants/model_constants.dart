import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';

class ModelInfo {
  const ModelInfo({
    required this.name,
    required this.apiName,
    required this.color,
    required this.backgroundColor,
    required this.icon,
    required this.subtitle,
  });

  final String name;
  final String apiName;
  final Color color;
  final Color backgroundColor;
  final IconData icon;
  final String subtitle;
}

class ModelConstants {
  ModelConstants._();

  static const models = [
    ModelInfo(
      name: 'MobileNet',
      apiName: 'mobilenet',
      color: AppColors.mobilenet,
      // Valeur de repli fixe (le rendu réel utilise context.colors,
      // voir _ModelCard._modelBackground) : on ne peut pas référencer
      // un champ d'instance de AppColors.dark dans une expression const.
      backgroundColor: Color(0xFF263414),
      icon: LucideIcons.zap,
      subtitle: 'Fast & Lightweight',
    ),
    ModelInfo(
      name: 'ResNet',
      apiName: 'resnet',
      color: AppColors.resnet,
      backgroundColor: Color(0xFF281638),
      icon: LucideIcons.boxes,
      subtitle: 'High Accuracy',
    ),
    ModelInfo(
      name: 'YOLO',
      apiName: 'yolo',
      color: AppColors.yolo,
      backgroundColor: Color(0xFF382414),
      icon: LucideIcons.target,
      subtitle: 'Object Detection',
    ),
  ];

  static const modelAccuracy = {
    'MobileNet': {
      'accuracy': '97.65%',
      'precision': '97.20%',
      'recall': '97.89%',
      'f1': '97.54%',
    },
    'ResNet': {
      'accuracy': '98.32%',
      'precision': '98.10%',
      'recall': '98.40%',
      'f1': '98.25%',
    },
    'YOLO': {
      'accuracy': '98.12%',
      'precision': '97.95%',
      'recall': '98.20%',
      'f1': '98.07%',
    },
  };

  static ModelInfo getModelByName(String name) {
    return models.firstWhere((m) => m.name == name, orElse: () => models.first);
  }

  static Color getModelColor(String name) {
    return getModelByName(name).color;
  }
}
