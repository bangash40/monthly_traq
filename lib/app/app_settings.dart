import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monthly_traq/app/home_layout.dart';

const _thousandsSeparatorKey = 'thousands_separator';
const _quickAddNotificationKey = 'quick_add_notification';
const _soundEffectsKey = 'sound_effects';
const _homeCardOrderKey = 'home_card_order';
const _homeCardsHiddenKey = 'home_cards_hidden';
const _hideAmountsKey = 'hide_amounts';
const _showPrivacyButtonKey = 'show_privacy_button';
const _hapticFeedbackKey = 'haptic_feedback';
const _dismissedWinKey = 'dismissed_budget_win';
const _lastWalletKey = 'last_wallet_id';
const _netWorthOffKey = 'net_worth_off';

/// The on/off preferences from the Profile tab, saved on this device.
class AppSettings extends ChangeNotifier {
  /// Groups digits in every amount ("120,000" vs "120000").
  bool thousandsSeparator = true;

  /// A light vibration on keypad taps, saving and deleting.
  bool hapticFeedback = true;

  // Remembered only for now — the notification and sounds aren't built yet.
  bool quickAddNotification = true;
  bool soundEffects = true;

  /// Which cards Home shows, and in what order.
  HomeLayout homeLayout = HomeLayout.defaults;

  /// Whether the balance card has the eye button that hides amounts. Off
  /// by default, so Home looks like it always has.
  bool showPrivacyButton = false;

  /// Privacy mode: Home shows "Rs. ••••" instead of amounts. Only takes
  /// effect while the privacy button is on.
  bool hideAmounts = false;

  bool get amountsHidden => showPrivacyButton && hideAmounts;

  /// The last month-end celebration closed on Home (a BudgetWin id), so it
  /// doesn't come back.
  String? dismissedBudgetWin;

  /// The wallet the last transaction was logged with — new ones start on
  /// it, since people mostly pay from the same place.
  String? lastWalletId;

  /// The parts Net worth leaves out (NetWorthPart names). The Home balance
  /// starts out left out: it may be the same money as the wallets.
  Set<String> netWorthOff = {'balance'};

  /// Home exactly as it comes out of the box.
  bool get isDefaultHome => homeLayout.isDefault && !showPrivacyButton;

  AppSettings({bool load = true}) {
    if (load) _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    thousandsSeparator = prefs.getBool(_thousandsSeparatorKey) ?? true;
    quickAddNotification = prefs.getBool(_quickAddNotificationKey) ?? true;
    soundEffects = prefs.getBool(_soundEffectsKey) ?? true;
    hapticFeedback = prefs.getBool(_hapticFeedbackKey) ?? true;
    dismissedBudgetWin = prefs.getString(_dismissedWinKey);
    lastWalletId = prefs.getString(_lastWalletKey);
    netWorthOff = {
      ...(prefs.getStringList(_netWorthOffKey) ?? ['balance']),
    };
    homeLayout = HomeLayout.fromNames(
      prefs.getStringList(_homeCardOrderKey),
      prefs.getStringList(_homeCardsHiddenKey),
    );
    showPrivacyButton = prefs.getBool(_showPrivacyButtonKey) ?? false;
    hideAmounts = prefs.getBool(_hideAmountsKey) ?? false;
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

  Future<void> setLastWalletId(String? id) async {
    if (id == lastWalletId) return;
    lastWalletId = id;
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_lastWalletKey);
    } else {
      await prefs.setString(_lastWalletKey, id);
    }
  }

  Future<void> setNetWorthPart(String part, bool counted) async {
    netWorthOff = counted
        ? ({...netWorthOff}..remove(part))
        : {...netWorthOff, part};
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_netWorthOffKey, [...netWorthOff]);
  }

  Future<void> dismissBudgetWin(String id) async {
    dismissedBudgetWin = id;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedWinKey, id);
  }

  Future<void> setHapticFeedback(bool value) {
    hapticFeedback = value;
    return _save(_hapticFeedbackKey, value);
  }

  Future<void> setSoundEffects(bool value) {
    soundEffects = value;
    return _save(_soundEffectsKey, value);
  }

  Future<void> setHideAmounts(bool value) {
    hideAmounts = value;
    return _save(_hideAmountsKey, value);
  }

  /// Turning the button off also shows the amounts again — otherwise
  /// they'd stay hidden with no way to reveal them.
  Future<void> setShowPrivacyButton(bool value) async {
    showPrivacyButton = value;
    if (!value && hideAmounts) await setHideAmounts(false);
    await _save(_showPrivacyButtonKey, value);
  }

  /// Puts Home back the way it comes out of the box.
  Future<void> resetHome() async {
    await setShowPrivacyButton(false);
    await setHomeLayout(HomeLayout.defaults);
  }

  Future<void> setHomeLayout(HomeLayout layout) async {
    if (layout == homeLayout) return;
    homeLayout = layout;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_homeCardOrderKey, layout.orderNames);
    await prefs.setStringList(_homeCardsHiddenKey, layout.hiddenNames);
  }
}
