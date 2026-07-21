import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreference {
  system('system', 'System', Icons.brightness_auto_rounded, ThemeMode.system),
  light('light', 'Light', Icons.light_mode_rounded, ThemeMode.light),
  dark('dark', 'Dark', Icons.dark_mode_rounded, ThemeMode.dark);

  const AppThemePreference(
    this.storageValue,
    this.label,
    this.icon,
    this.themeMode,
  );

  final String storageValue;
  final String label;
  final IconData icon;
  final ThemeMode themeMode;

  static AppThemePreference fromStorageValue(String? value) {
    for (final AppThemePreference preference in values) {
      if (preference.storageValue == value) {
        return preference;
      }
    }

    return AppThemePreference.system;
  }
}

class AppThemeController extends ChangeNotifier {
  AppThemeController(this._preference);

  static const String _storageKey = 'theme_mode';

  AppThemePreference _preference;

  AppThemePreference get preference => _preference;
  ThemeMode get themeMode => _preference.themeMode;
  String get preferenceLabel => _preference.label;

  static Future<AppThemeController> load() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? savedValue = preferences.getString(_storageKey);
    return AppThemeController(AppThemePreference.fromStorageValue(savedValue));
  }

  Future<void> updatePreference(AppThemePreference preference) async {
    if (_preference == preference) {
      return;
    }

    _preference = preference;
    notifyListeners();

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, preference.storageValue);
  }
}

class AppThemeScope extends InheritedNotifier<AppThemeController> {
  const AppThemeScope({
    super.key,
    required AppThemeController notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppThemeController of(BuildContext context) {
    final AppThemeScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppThemeScope>();
    assert(scope != null, 'No AppThemeScope found in context');
    return scope!.notifier!;
  }

  static AppThemeController read(BuildContext context) {
    final InheritedElement? element = context
        .getElementForInheritedWidgetOfExactType<AppThemeScope>();
    final AppThemeScope? scope = element?.widget as AppThemeScope?;
    assert(scope != null, 'No AppThemeScope found in context');
    return scope!.notifier!;
  }
}
