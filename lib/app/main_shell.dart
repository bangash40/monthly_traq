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

  /// Times each tab has been opened (Home counts as opened at launch), so a
  /// tab's charts and numbers animate when it's opened, not out of sight.
  final _visits = [1, 0, 0, 0];

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
    _tabOpacity.dispose();
    _tabFade.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
      _visits[index]++;
    });
    if (!Motion.reduced(context)) _tabFade.forward(from: 0);
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
              child: !isOffline || isLoading
                  ? const SizedBox(width: double.infinity)
                  : Container(
                      width: double.infinity,
                      color: c.tint(c.warningFill),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        MediaQuery.paddingOf(context).top + 6,
                        16,
                        6,
                      ),
                      child: Text(
                        "You're offline — showing saved data",
                        textAlign: TextAlign.center,
                        style: AppText.caption.copyWith(color: c.warning),
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
                            TabVisit(visit: _visits[i], child: screen),
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
