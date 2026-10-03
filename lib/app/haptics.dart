import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/app_settings.dart';

/// The kinds of vibration the app uses, from lightest to strongest.
enum Haptic {
  /// A keypad key or a category tile.
  tick,

  /// A small confirmation, like Undo.
  tap,

  /// Something saved.
  success,

  /// Something deleted.
  delete,
}

const _channel = MethodChannel('monthlytraq/haptics');

/// Plays [kind], unless Profile → General → Haptic feedback is off.
void haptic(BuildContext context, Haptic kind) {
  if (context.read<AppSettings>().hapticFeedback) playHaptic(kind);
}

/// Plays [kind] without checking the setting — for callers that checked it
/// already and may outlive their widget (a snackbar's Undo).
///
/// On Android this drives the vibration motor directly (MainActivity.kt),
/// so it works even when the phone's own touch-feedback setting is off —
/// the app's switch is what decides. Elsewhere it uses Flutter's haptics.
void playHaptic(Haptic kind) {
  if (defaultTargetPlatform == TargetPlatform.android) {
    _channel
        .invokeMethod<void>('vibrate', {'kind': kind.name})
        .catchError((Object _) {}); // No motor or no channel: stay silent.
    return;
  }
  switch (kind) {
    case Haptic.tick:
      HapticFeedback.selectionClick();
    case Haptic.tap:
      HapticFeedback.lightImpact();
    case Haptic.success:
      HapticFeedback.mediumImpact();
    case Haptic.delete:
      HapticFeedback.heavyImpact();
  }
}
