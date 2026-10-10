import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/launch_intro.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/analytics/analytics_screen.dart';
import 'package:monthly_traq/features/dashboard/dashboard_screen.dart';
import 'package:monthly_traq/features/settings/profile_screen.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/features/transactions/transactions_screen.dart';
import 'package:monthly_traq/services/transactions_repository.dart';
import 'package:monthly_traq/widgets/motion.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  /// 1 once each tab has been opened, so a tab's charts and numbers animate
  /// the first time it's seen, not out of sight — and not again on every
  /// tab switch. Home counts as opened once the launch intro has revealed
  /// it.
  final _visits = [0, 0, 0, 0];

  /// Whether the app was offline at the last build, to notice changes.
  bool _wasOffline = false;

  /// Whether the offline banner is showing. It waits a moment first: right
  /// after the app opens it reads from the phone's copy before reaching the
  /// server, and that blip shouldn't flash "offline" (or "Back online").
  bool _showOffline = false;
  Timer? _offlineTimer;

  /// Whether the app has reached the server since it opened. Until then it
  /// waits longer before saying "offline", since connecting at startup can
  /// take a few seconds.
  bool _beenOnline = false;

  /// True for a moment after the connection returns, while the banner says
  /// "Back online" in green before it goes.
  bool _backOnline = false;
  Timer? _backOnlineTimer;

  void _trackConnection({required bool offline, required bool loaded}) {
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
      // Only say "Back online" if the person was told they were offline.
      _showOffline = false;
      _backOnline = true;
      _backOnlineTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _backOnline = false);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (LaunchIntro.revealed.value) {
      _visits[0] = 1;
    } else {
      LaunchIntro.revealed.addListener(_onRevealed);
    }
  }

  void _onRevealed() {
    LaunchIntro.revealed.removeListener(_onRevealed);
    if (mounted) setState(() => _visits[0] = 1);
  }

  /// One scroll position per tab. Switching tabs keeps each where it was
  /// left (as most apps do); tapping the tab you're already on scrolls it
  /// back to the top.
  final _scrollers = List.generate(4, (_) => ScrollController());

  /// Fades the newly picked tab in, so switching tabs doesn't jump.
  late final _tabFade = AnimationController(
    vsync: this,
    duration: Motion.short,
    value: 1,
  );
  late final _tabOpacity = CurvedAnimation(
    parent: _tabFade,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _offlineTimer?.cancel();
    _backOnlineTimer?.cancel();
    LaunchIntro.revealed.removeListener(_onRevealed);
    for (final scroller in _scrollers) {
      scroller.dispose();
    }
    _tabOpacity.dispose();
    _tabFade.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _selectedIndex) {
      _scrollToTop(index);
      return;
    }
    setState(() {
      _selectedIndex = index;
      // Animates the first time it's opened; later visits don't replay.
      _visits[index] = 1;
    });
    if (!Motion.reduced(context)) _tabFade.forward(from: 0);
  }

  void _scrollToTop(int index) {
    final scroller = _scrollers[index];
    if (!scroller.hasClients || scroller.offset <= 0) return;
    scroller.animateTo(
      0,
      duration: Motion.of(context, const Duration(milliseconds: 450)),
      curve: Motion.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLoading = context.select<TransactionsRepository, bool>(
      (repo) => repo.isLoading,
    );
    final isOffline = context.select<TransactionsRepository, bool>(
      (repo) => repo.isOffline,
    );
    if (!isLoading) LaunchIntro.markReady();
    _trackConnection(offline: isOffline && !isLoading, loaded: !isLoading);

    final screens = [
      DashboardScreen(
        onSeeAllTransactions: () => _select(1),
        onSeeAllSpending: () => _select(2),
      ),
      const TransactionsScreen(),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];

    // Back on any other tab returns to Home; back on Home leaves the app —
    // the usual Android pattern. Pages opened on top of a tab (Theme,
    // Privacy policy…) still close first, since they're separate routes.
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: !_showOffline && !_backOnline
                  ? const SizedBox(width: double.infinity)
                  : Container(
                      width: double.infinity,
                      color: _backOnline
                          ? c.tint(c.incomeFill)
                          : c.tint(c.warningFill),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        MediaQuery.paddingOf(context).top + 6,
                        16,
                        6,
                      ),
                      child: Text(
                        _backOnline
                            ? 'Back online'
                            : "You're offline — showing saved data",
                        textAlign: TextAlign.center,
                        style: AppText.caption.copyWith(
                          color: _backOnline ? c.income : c.warning,
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FadeTransition(
                      opacity: _tabOpacity,
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                          for (final (i, screen) in screens.indexed)
                            TabVisit(
                              visit: _visits[i],
                              // Each tab's list picks up its own controller.
                              child: PrimaryScrollController(
                                controller: _scrollers[i],
                                child: screen,
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface,
            border: Border(top: BorderSide(color: c.hairline)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: _selectedIndex == 0,
                    onTap: () => _select(0),
                  ),
                  _NavItem(
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long,
                    label: 'Transactions',
                    isSelected: _selectedIndex == 1,
                    onTap: () => _select(1),
                  ),
                  _AddButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditTransactionScreen(),
                      ),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.donut_large,
                    selectedIcon: Icons.donut_large,
                    label: 'Analytics',
                    isSelected: _selectedIndex == 2,
                    onTap: () => _select(2),
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: 'Profile',
                    isSelected: _selectedIndex == 3,
                    onTap: () => _select(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The + in the middle of the bottom bar. It sits fully inside the bar (not
/// floating above it), so it never covers the content behind it; the filled
/// brand color keeps it the most visible action.
class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Center(
        child: Tooltip(
          message: 'Add transaction',
          child: Semantics(
            button: true,
            label: 'Add transaction',
            excludeSemantics: true,
            child: Material(
              color: c.primary,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(18),
                child: SizedBox.square(
                  dimension: 52,
                  child: Icon(Icons.add, color: c.onPrimary, size: 30),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = isSelected ? c.accent : c.muted;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                // The new tab's pill fades in; the old one goes at once, so
                // two tabs never look selected together.
                duration: isSelected
                    ? Motion.of(context, Motion.short)
                    : Duration.zero,
                width: 60,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? c.primarySoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: AppText.tiny.copyWith(
                    fontSize: 12,
                    color: color,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
