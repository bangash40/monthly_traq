import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monthly_traq/widgets/motion.dart';
import 'package:monthly_traq/widgets/ui.dart';

/// Picks up where the native splash screen leaves off: the same calendar
/// page on the same background, then its spending donut sweeps round, and
/// once the first real screen is ready (Home with its data, or login) the
/// whole thing fades into the app. Plays once per launch and is skipped when
/// the phone's "Remove animations" setting is on.
class LaunchIntro extends StatefulWidget {
  final Widget child;

  const LaunchIntro({super.key, required this.child});

  /// The splash screen's background and the icon's colors (Sage), from
  /// pubspec.yaml's flutter_native_splash and tool/render_icon.py.
  static const background = Color(0xFFF2F6F3);
  static const brand = Color(0xFF2F6B55);

  /// The longest the finished logo waits for the app before fading anyway.
  static const maxWait = Duration(seconds: 3);

  static final _ready = ValueNotifier(false);

  /// Turns true once the intro has fully faded away (or at once when it's
  /// skipped), so Home can hold its count-up and charts until they're
  /// actually visible instead of playing them behind the intro.
  static final revealed = ValueNotifier(false);

  /// Called by the first real screen (Home with its data, login or
  /// onboarding) once it's on display, so the intro can fade onto it rather
  /// than onto a loading spinner.
  static void markReady() {
    if (_ready.value) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ready.value = true);
  }

  @override
  State<LaunchIntro> createState() => _LaunchIntroState();
}

class _LaunchIntroState extends State<LaunchIntro>
    with TickerProviderStateMixin {
  /// Plays once per app process; Flutter can rebuild the app's root.
  static bool _played = false;

  late final _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final _sweepCurve = CurvedAnimation(
    parent: _sweep,
    curve: Curves.easeOutCubic,
  );
  late final _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  late bool _showing = !_played;
  bool _started = false;
  bool _timedOut = false;
  Timer? _timeout;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_showing || _started) return;
    _started = true;
    _played = true;
    if (Motion.reduced(context)) {
      _showing = false;
      LaunchIntro.revealed.value = true;
      return;
    }
    LaunchIntro._ready.addListener(_maybeFinish);
    _timeout = Timer(LaunchIntro.maxWait, () {
      _timedOut = true;
      _maybeFinish();
    });
    _sweep.forward().then((_) => _maybeFinish());
  }

  /// Fades out once the donut is drawn and the app underneath is ready.
  void _maybeFinish() {
    if (!mounted || !_showing || _fade.isAnimating || !_sweep.isCompleted) {
      return;
    }
    if (!LaunchIntro._ready.value && !_timedOut) return;
    _timeout?.cancel();
    _fade.forward().then((_) {
      LaunchIntro.revealed.value = true;
      if (mounted) setState(() => _showing = false);
    });
  }

  @override
  void dispose() {
    LaunchIntro._ready.removeListener(_maybeFinish);
    _timeout?.cancel();
    _sweepCurve.dispose();
    _sweep.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The app stays the Stack's first child whether or not the intro is
    // showing — changing the structure around it would rebuild the whole
    // app from scratch the moment the intro ends.
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_showing)
          AbsorbPointer(
            child: FadeTransition(
              opacity: ReverseAnimation(_fade),
              child: ColoredBox(
                color: LaunchIntro.background,
                child: Center(
                  // The splash image is a 256dp square whose 100-unit icon
                  // grid spans 100 / 107 of it (see tool/render_icon.py), so
                  // the logo lands exactly where the splash drew it.
                  child: SizedBox.square(
                    dimension: 256 * 100 / 107,
                    child: AnimatedBuilder(
                      animation: _sweepCurve,
                      builder: (context, _) => CustomPaint(
                        painter: MonthDonutPainter(
                          brand: LaunchIntro.brand,
                          progress: _sweepCurve.value,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
