import 'package:flutter/material.dart';
import 'package:plant_ai_mobile/core/l10n/app_strings.dart';

class AppController extends ChangeNotifier {
  AppLanguage language = AppLanguage.en;
  ThemeMode themeMode = ThemeMode.dark;

  AppStrings get strings => AppStrings(language);

  bool get isDark => themeMode == ThemeMode.dark;

  String get languageLabel => language == AppLanguage.en ? 'ENG' : 'FR';

  void toggleLanguage() {
    language = language == AppLanguage.en ? AppLanguage.fr : AppLanguage.en;
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    super.key,
    required AppController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.notifier!;
  }
}

extension AppContext on BuildContext {
  AppController get settings => AppScope.of(this);

  AppStrings get l10n => settings.strings;
}
