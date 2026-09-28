import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _thousandsSeparatorKey = 'thousands_separator';
const _quickAddNotificationKey = 'quick_add_notification';
const _soundEffectsKey = 'sound_effects';

/// The on/off preferences from the Profile tab, saved on this device.
class AppSettings extends ChangeNotifier {
  /// Groups digits in every amount ("120,000" vs "120000").
  bool thousandsSeparator = true;

  // Remembered only for now — the notification and sounds aren't built yet.
  bool quickAddNotification = true;
  bool soundEffects = true;

  AppSettings({bool load = true}) {
    if (load) _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    thousandsSeparator = prefs.getBool(_thousandsSeparatorKey) ?? true;
    quickAddNotification = prefs.getBool(_quickAddNotificationKey) ?? true;
    soundEffects = prefs.getBool(_soundEffectsKey) ?? true;
    notifyListeners();
  }

  Future<void> _save(String key, bool value) async {
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> setThousandsSeparator(bool value) {
    thousandsSeparator = value;
    return _save(_thousandsSeparatorKey, value);
  }

  Future<void> setQuickAddNotification(bool value) {
    quickAddNotification = value;
    return _save(_quickAddNotificationKey, value);
  }

  Future<void> setSoundEffects(bool value) {
    soundEffects = value;
    return _save(_soundEffectsKey, value);
  }
}
