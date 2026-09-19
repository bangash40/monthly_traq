import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monthly_traq/app/theme.dart';

const _themeModeKey = 'theme_mode';
const _lightPresetKey = 'theme_light_preset';
const _darkPresetKey = 'theme_dark_preset';

/// Holds the user's chosen appearance (system/light/dark) and color palette
/// preset for each brightness, persisting all of it locally — some devices
/// make the OS dark-mode setting hard to find or don't expose it
/// consistently, and the palette pick has no OS equivalent at all.
class ThemeController extends ChangeNotifier {
  ThemeMode mode = ThemeMode.system;
  String lightPresetId = kDefaultLightPresetId;
  String darkPresetId = kDefaultDarkPresetId;

  AppThemePreset get lightPreset =>
      presetById(lightPresetId, kLightThemePresets);
  AppThemePreset get darkPreset => presetById(darkPresetId, kDarkThemePresets);

  ThemeController() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeModeKey);
    mode = switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    lightPresetId = prefs.getString(_lightPresetKey) ?? kDefaultLightPresetId;
    darkPresetId = prefs.getString(_darkPresetKey) ?? kDefaultDarkPresetId;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode newMode) async {
    mode = newMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, newMode.name);
  }

  Future<void> setLightPreset(String id) async {
    lightPresetId = id;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lightPresetKey, id);
  }

  Future<void> setDarkPreset(String id) async {
    darkPresetId = id;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_darkPresetKey, id);
  }
}
