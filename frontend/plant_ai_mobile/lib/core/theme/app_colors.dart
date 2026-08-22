import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.cardBackground,
    required this.surface,
    required this.headerBackground,
    required this.borderDefault,
    required this.borderSubtle,
    required this.borderDashed,
    required this.progressTrack,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textGray400,
    required this.textGray300,
    required this.tagline,
    required this.mobilenetBg,
    required this.resnetBg,
    required this.yoloBg,
    required this.healthyBg,
    required this.infectedBg,
    required this.badgeBg,
    required this.languageButtonBg,
  });

  final Color background;
  final Color cardBackground;
  final Color surface;
  final Color headerBackground;
  final Color borderDefault;
  final Color borderSubtle;
  final Color borderDashed;
  final Color progressTrack;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textGray400;
  final Color textGray300;
  final Color tagline;
  final Color mobilenetBg;
  final Color resnetBg;
  final Color yoloBg;
  final Color healthyBg;
  final Color infectedBg;
  final Color badgeBg;
  final Color languageButtonBg;

  static const primary = Color(0xFF84CC16);
  static const primaryHover = Color(0xFFA3E635);

  static const mobilenet = Color(0xFF84CC16);
  static const resnet = Color(0xFFA855F7);
  static const yolo = Color(0xFFF97316);

  static const metricCyan = Color(0xFF06B6D4);
  static const metricGreen = Color(0xFF22C55E);
  static const metricBlue = Color(0xFF3B82F6);
  static const metricYellow = Color(0xFFEAB308);

  static const healthyText = Color(0xFF16A34A);
  static const infectedText = Color(0xFFEF4444);

  static const detectGradientStart = Color(0xFF293F09);
  static const detectGradientEnd = Color(0xFF095A1C);

  static const chartColors = [mobilenet, resnet, yolo];

  static const dark = AppColors(
    background: Color(0xFF0F1117),
    cardBackground: Color(0xFF15171E),
    surface: Color(0xFF080A0D),
    headerBackground: Color(0xFF000000),
    borderDefault: Color(0xFF2A2E38),
    borderSubtle: Color(0xFF22252C),
    borderDashed: Color(0xFF3A3F48),
    progressTrack: Color(0xFF252A32),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF6B7280),
    textGray400: Color(0xFF9CA3AF),
    textGray300: Color(0xFFD1D5DB),
    tagline: Color(0xFFFFFBEB),
    mobilenetBg: Color(0xFF263414),
    resnetBg: Color(0xFF281638),
    yoloBg: Color(0xFF382414),
    healthyBg: Color(0xFF052E16),
    infectedBg: Color(0xFF450A0A),
    badgeBg: Color(0xFF111827),
    languageButtonBg: Color(0xFF0F1117),
  );

  static const light = AppColors(
    background: Color(0xFFFAFBF7),
    cardBackground: Color(0xFFFFFFFF),
    surface: Color(0xFFF5F8F0),
    headerBackground: Color(0xFFFFFFFF),
    borderDefault: Color(0xFFE3E9D6),
    borderSubtle: Color(0xFFECF1E4),
    borderDashed: Color(0xFFD3DDC0),
    progressTrack: Color(0xFFE7EEDC),
    textPrimary: Color(0xFF1B2A1E),
    textSecondary: Color(0xFF5B6472),
    textMuted: Color(0xFF7A8390),
    textGray400: Color(0xFF7A8390),
    textGray300: Color(0xFF454F5B),
    tagline: Color(0xFF243026),
    mobilenetBg: Color(0xFFEFF9D6),
    resnetBg: Color(0xFFF8EFFF),
    yoloBg: Color(0xFFFFF3E2),
    healthyBg: Color(0xFFE6FCEC),
    infectedBg: Color(0xFFFFEEEE),
    badgeBg: Color(0xFFF5F8F0),
    languageButtonBg: Color(0xFF4D7C1E),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? cardBackground,
    Color? surface,
    Color? headerBackground,
    Color? borderDefault,
    Color? borderSubtle,
    Color? borderDashed,
    Color? progressTrack,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textGray400,
    Color? textGray300,
    Color? tagline,
    Color? mobilenetBg,
    Color? resnetBg,
    Color? yoloBg,
    Color? healthyBg,
    Color? infectedBg,
    Color? badgeBg,
    Color? languageButtonBg,
  }) {
    return AppColors(
      background: background ?? this.background,
      cardBackground: cardBackground ?? this.cardBackground,
      surface: surface ?? this.surface,
      headerBackground: headerBackground ?? this.headerBackground,
      borderDefault: borderDefault ?? this.borderDefault,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDashed: borderDashed ?? this.borderDashed,
      progressTrack: progressTrack ?? this.progressTrack,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textGray400: textGray400 ?? this.textGray400,
      textGray300: textGray300 ?? this.textGray300,
      tagline: tagline ?? this.tagline,
      mobilenetBg: mobilenetBg ?? this.mobilenetBg,
      resnetBg: resnetBg ?? this.resnetBg,
      yoloBg: yoloBg ?? this.yoloBg,
      healthyBg: healthyBg ?? this.healthyBg,
      infectedBg: infectedBg ?? this.infectedBg,
      badgeBg: badgeBg ?? this.badgeBg,
      languageButtonBg: languageButtonBg ?? this.languageButtonBg,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      headerBackground: Color.lerp(headerBackground, other.headerBackground, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDashed: Color.lerp(borderDashed, other.borderDashed, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textGray400: Color.lerp(textGray400, other.textGray400, t)!,
      textGray300: Color.lerp(textGray300, other.textGray300, t)!,
      tagline: Color.lerp(tagline, other.tagline, t)!,
      mobilenetBg: Color.lerp(mobilenetBg, other.mobilenetBg, t)!,
      resnetBg: Color.lerp(resnetBg, other.resnetBg, t)!,
      yoloBg: Color.lerp(yoloBg, other.yoloBg, t)!,
      healthyBg: Color.lerp(healthyBg, other.healthyBg, t)!,
      infectedBg: Color.lerp(infectedBg, other.infectedBg, t)!,
      badgeBg: Color.lerp(badgeBg, other.badgeBg, t)!,
      languageButtonBg: Color.lerp(languageButtonBg, other.languageButtonBg, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}
