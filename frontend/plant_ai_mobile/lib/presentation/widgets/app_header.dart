import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:plant_ai_mobile/core/app_controller.dart';
import 'package:plant_ai_mobile/core/constants/api_constants.dart';
import 'package:plant_ai_mobile/core/layout/breakpoints.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  Future<void> _downloadApp(BuildContext context) async {
    final l10n = context.l10n;

    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.alreadyOnApp)),
      );
      return;
    }

    final uri = Uri.parse(ApiConstants.appDownloadUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.downloadUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final settings = context.settings;
    final l10n = context.l10n;
    final isDesktop = AppBreakpoints.isDesktopWidth(
      MediaQuery.sizeOf(context).width,
    );

    return Container(
      color: colors.headerBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.leaf, color: AppColors.primary, size: 28),
                      const SizedBox(width: 8),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 24,
                            color: colors.tagline,
                            fontWeight: FontWeight.w400,
                          ),
                          children: const [
                            TextSpan(text: 'Plant'),
                            TextSpan(
                              text: 'AI',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appTagline,
                    style: TextStyle(
                      color: colors.textMuted.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isDesktop)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _downloadApp(context),
                  icon: const Icon(LucideIcons.download, size: 16),
                  label: Text(l10n.downloadApp),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              )
            else
              IconButton(
                tooltip: l10n.downloadApp,
                onPressed: () => _downloadApp(context),
                icon: const Icon(LucideIcons.download, color: AppColors.primary),
              ),
            IconButton(
              tooltip: settings.isDark ? 'Light' : 'Dark',
              onPressed: settings.toggleTheme,
              icon: Icon(
                settings.isDark ? LucideIcons.sun : LucideIcons.moon,
                color: AppColors.primary,
              ),
            ),
            InkWell(
              onTap: settings.toggleLanguage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colors.languageButtonBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  settings.languageLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
