import 'package:flutter/material.dart';

/// The app's animation timings. Every animation goes through [Motion.of],
/// so when the phone's "Remove animations" accessibility setting is on,
/// everything simply appears in its final state.
abstract final class Motion {
  /// Small changes: colors, highlights, tab fades.
  static const short = Duration(milliseconds: 220);

  /// Numbers counting up.
  static const medium = Duration(milliseconds: 650);

  /// Bars filling and charts drawing in.
  static const long = Duration(milliseconds: 900);

  static const curve = Curves.easeOutCubic;

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or no time at all when animations are turned off.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}

/// 1 once the bottom-bar tab this widget sits in has been opened, 0 before.
/// The tabs are all built up front, so without this a tab's animations
/// would play out of sight at launch; keying them on it plays them the
/// first time the tab is opened — once per app launch, not on every tab
/// switch. Outside the tabs (pushed screens) it's 0.
class TabVisit extends InheritedWidget {
  final int visit;

  const TabVisit({super.key, required this.visit, required super.child});

  static int of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabVisit>()?.visit ?? 0;

  @override
  bool updateShouldNotify(TabVisit old) => old.visit != visit;
}

/// Counts a number up to [value] — from zero when it's first shown (or its
/// tab is first opened), then from the old value whenever it changes —
/// handing each frame's number to [builder].
class CountUp extends StatelessWidget {
  final double value;
  final Widget Function(BuildContext context, double value) builder;
  final Duration duration;

  const CountUp({
    super.key,
    required this.value,
    required this.builder,
    this.duration = Motion.medium,
  });

  @override
  Widget build(BuildContext context) {
    // A whole target counts in whole steps, so "Rs. 1,234.56" never flashes
    // up on the way to "Rs. 4,330".
    final whole = value == value.roundToDouble();
    return TweenAnimationBuilder<double>(
      key: ValueKey(TabVisit.of(context)),
      tween: Tween(begin: 0, end: value),
      duration: Motion.of(context, duration),
      curve: Motion.curve,
      builder: (context, v, _) =>
          builder(context, whole ? v.roundToDouble() : v),
    );
  }
}

/// Plays a 0 → 1 progress when first shown (or its tab is first opened) and
/// again whenever [trigger] changes (another month, other data) — for
/// charts that draw themselves in.
class GrowIn extends StatelessWidget {
  final Object? trigger;
  final Widget Function(BuildContext context, double progress) builder;
  final Duration duration;

  const GrowIn({
    super.key,
    required this.trigger,
    required this.builder,
    this.duration = Motion.long,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey((trigger, TabVisit.of(context))),
      tween: Tween(begin: 0, end: 1),
      duration: Motion.of(context, duration),
      curve: Motion.curve,
      builder: (context, progress, _) => builder(context, progress),
    );
  }
}
