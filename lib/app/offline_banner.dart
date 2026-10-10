import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

/// Tells the person, across every screen, when the app can't reach the
/// server. When the connection drops a strip slides in saying changes will
/// sync later; after a few seconds it shrinks back so only the status bar
/// stays amber — a quiet sign that costs no space, however long they're
/// offline. When the connection returns the status bar turns green for a
/// moment, then goes.
///
/// The strip takes the status bar's place, and appears and goes in the same
/// frame the screen below gives up or gets back its status-bar gap, so the
/// space at the top never changes and nothing jumps.
class OfflineBannerFrame extends StatefulWidget {
  final Widget child;

  const OfflineBannerFrame({super.key, required this.child});

  @override
  State<OfflineBannerFrame> createState() => _OfflineBannerFrameState();
}

class _OfflineBannerFrameState extends State<OfflineBannerFrame> {
  /// How long the message stays before the strip shrinks to the status bar.
  static const _messageTime = Duration(seconds: 5);

  /// How long the status bar stays green once the connection is back.
  static const _backOnlineTime = Duration(seconds: 2);

  /// Whether the app was offline at the last build, to notice changes.
  bool _wasOffline = false;

  /// Whether the app has reached the server since it opened. Right after
  /// opening it reads from the phone's copy before reaching the server, so
  /// it waits longer before calling that "offline".
  bool _beenOnline = false;

  /// Shown only once offline for a moment, so a blip doesn't flash it.
  bool _showOffline = false;
  bool _showMessage = false;
  bool _backOnline = false;

  Timer? _offlineTimer;
  Timer? _messageTimer;
  Timer? _backOnlineTimer;

  @override
  void dispose() {
    _offlineTimer?.cancel();
    _messageTimer?.cancel();
    _backOnlineTimer?.cancel();
    super.dispose();
  }

  void _track({required bool offline, required bool loaded}) {
    if (loaded && !offline) _beenOnline = true;
    if (offline == _wasOffline) return;
    _wasOffline = offline;
    _offlineTimer?.cancel();
    _messageTimer?.cancel();
    _backOnlineTimer?.cancel();
    if (offline) {
      _backOnline = false;
      _offlineTimer = Timer(Duration(seconds: _beenOnline ? 2 : 6), () {
        if (!mounted) return;
        setState(() {
          _showOffline = true;
          _showMessage = true;
        });
        _messageTimer = Timer(_messageTime, () {
          if (mounted) setState(() => _showMessage = false);
        });
      });
    } else if (_showOffline) {
      // Green only if the person was told they were offline.
      _showOffline = false;
      _showMessage = false;
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
        if (showStrip)
          Material(
            // The green is mixed in stronger than the amber: it's only up
            // for a moment, so it has to read clearly as "back".
            color: _backOnline
                ? Color.alphaBlend(
                    c.incomeFill.withValues(alpha: 0.38),
                    c.surface,
                  )
                // Light mode's usual tint is close to cream, so the amber is
                // mixed in a bit stronger there to still read as a sign.
                : Color.alphaBlend(
                    c.warningFill.withValues(alpha: c.isDark ? 0.18 : 0.30),
                    c.surface,
                  ),
            // Shrunk to the status bar, it still tells screen readers.
            child: Semantics(
              container: true,
              liveRegion: true,
              label: _backOnline
                  ? 'Back online'
                  : _showMessage
                  ? null
                  : 'You\'re offline',
              child: Padding(
                padding: EdgeInsets.only(top: top),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: SizedBox(
                    width: double.infinity,
                    child: _showMessage
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                            child: Text(
                              'You\'re offline. Changes will sync when '
                              'you\'re back.',
                              textAlign: TextAlign.center,
                              style: AppText.caption.copyWith(color: c.warning),
                            ),
                          )
                        : null,
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
