import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

/// Tells the person, across every screen, when the app can't reach the
/// server: a strip across the top while offline, which turns green and says
/// "Back online" for a moment when the connection returns.
///
/// The strip takes the status bar's place, so the screens below don't add
/// their own gap for it.
class OfflineBannerFrame extends StatefulWidget {
  final Widget child;

  const OfflineBannerFrame({super.key, required this.child});

  @override
  State<OfflineBannerFrame> createState() => _OfflineBannerFrameState();
}

class _OfflineBannerFrameState extends State<OfflineBannerFrame> {
  /// How long "Back online" stays once the connection is back.
  static const _backOnlineTime = Duration(seconds: 2);

  /// Whether the app was offline at the last build, to notice changes.
  bool _wasOffline = false;

  /// Whether the app has reached the server since it opened. Right after
  /// opening it reads from the phone's copy before reaching the server, so
  /// it waits longer before calling that "offline".
  bool _beenOnline = false;

  /// Shown only once offline for a moment, so a blip doesn't flash it.
  bool _showOffline = false;
  bool _backOnline = false;

  Timer? _offlineTimer;
  Timer? _backOnlineTimer;

  @override
  void dispose() {
    _offlineTimer?.cancel();
    _backOnlineTimer?.cancel();
    super.dispose();
  }

  void _track({required bool offline, required bool loaded}) {
    if (loaded && !offline) _beenOnline = true;
    if (offline == _wasOffline) return;
    _wasOffline = offline;
    _offlineTimer?.cancel();
    _backOnlineTimer?.cancel();
    if (offline) {
      _backOnline = false;
      _offlineTimer = Timer(Duration(seconds: _beenOnline ? 2 : 6), () {
        if (mounted) setState(() => _showOffline = true);
      });
    } else if (_showOffline) {
      // "Back online" only if the person was told they were offline.
      _showOffline = false;
      _backOnline = true;
      _backOnlineTimer = Timer(_backOnlineTime, () {
        if (mounted) setState(() => _backOnline = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loaded = context.select<TransactionsRepository, bool>(
      (repo) => !repo.isLoading,
    );
    final offline = context.select<TransactionsRepository, bool>(
      (repo) => repo.isOffline && !repo.isLoading,
    );
    _track(offline: offline, loaded: loaded);
    final c = context.colors;
    final mediaQuery = MediaQuery.of(context);
    final top = mediaQuery.padding.top;
    final showStrip = _showOffline || _backOnline;

    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: !showStrip
              ? const SizedBox(width: double.infinity)
              : Material(
                  color: _backOnline
                      ? c.tint(c.incomeFill)
                      : c.tint(c.warningFill),
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, top + 6, 16, 6),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          _backOnline
                              ? 'Back online'
                              : 'You\'re offline. Changes will sync when '
                                    'you\'re back.',
                          textAlign: TextAlign.center,
                          style: AppText.caption.copyWith(
                            color: _backOnline ? c.income : c.warning,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        Expanded(
          // Always the same widget here, so the screens below keep their
          // state when the strip comes and goes.
          child: MediaQuery(
            data: mediaQuery.copyWith(
              padding: showStrip
                  ? mediaQuery.padding.copyWith(top: 0)
                  : mediaQuery.padding,
              viewPadding: showStrip
                  ? mediaQuery.viewPadding.copyWith(top: 0)
                  : mediaQuery.viewPadding,
            ),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
