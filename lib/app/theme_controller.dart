import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monthly_traq/app/theme.dart';

const _themeModeKey = 'theme_mode';
const _themeIdKey = 'theme_id';
const _fontSizeStepKey = 'font_size_step';

/// Text scale factors for the Text size slider's stops, smallest first.
const kFontScaleSteps = [0.9, 1.0, 1.12, 1.25];
const kFontSizeLabels = ['Small', 'Default', 'Large', 'Largest'];
const kDefaultFontSizeStep = 1;

/// The user's appearance choices, saved on this device: one theme (each
/// has a light and a dark palette), System / Light / Dark mode, and text
/// size.
class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;
  String themeId = kDefaultThemeId;
  int fontSizeStep = kDefaultFontSizeStep;

  ThemeController({bool load = true}) {
    if (load) _load();
  }

  AppTheme get theme => themeById(themeId);
  double get fontScale => kFontScaleSteps[fontSizeStep];
  String get fontSizeLabel => kFontSizeLabels[fontSizeStep];

  String get modeLabel => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    mode = switch (prefs.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    themeId = themeById(prefs.getString(_themeIdKey) ?? kDefaultThemeId).id;
    final step = prefs.getInt(_fontSizeStepKey);
    if (step != null && step >= 0 && step < kFontScaleSteps.length) {
      fontSizeStep = step;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode newMode) async {
    mode = newMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, newMode.name);
  }

  Future<void> setTheme(String id) async {
    themeId = themeById(id).id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeIdKey, themeId);
  }

  Future<void> setFontSizeStep(int step) async {
    fontSizeStep = step.clamp(0, kFontScaleSteps.length - 1);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_fontSizeStepKey, fontSizeStep);
  }
}
