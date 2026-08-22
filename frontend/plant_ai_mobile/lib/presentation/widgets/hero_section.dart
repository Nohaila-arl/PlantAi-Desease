import 'package:flutter/material.dart';
import 'package:plant_ai_mobile/core/app_controller.dart';
import 'package:plant_ai_mobile/core/layout/breakpoints.dart';
import 'package:plant_ai_mobile/core/theme/app_colors.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHeroImage({required double width}) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5),
              blurRadius: 50,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/hero.png',
          width: width,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildHeroText({required double titleSize}) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.detectPlant,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        Text(
          l10n.diseasesWithAi,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.heroSubtitle,
          style: TextStyle(
            color: colors.textGray400,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = AppBreakpoints.isDesktopWidth(constraints.maxWidth);

        return Container(
          color: colors.headerBackground,
          padding: EdgeInsets.fromLTRB(
            isDesktop ? 40 : 24,
            16,
            isDesktop ? 40 : 24,
            32,
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildHeroText(titleSize: 48)),
                    const SizedBox(width: 32),
                    _buildHeroImage(width: 420),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroText(titleSize: 36),
                    const SizedBox(height: 24),
                    Center(child: _buildHeroImage(width: 280)),
                  ],
                ),
        );
      },
    );
  }
}
