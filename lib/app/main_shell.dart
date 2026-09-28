import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/text_styles.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/analytics/analytics_screen.dart';
import 'package:monthly_traq/features/dashboard/dashboard_screen.dart';
import 'package:monthly_traq/features/settings/profile_screen.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/features/transactions/transactions_screen.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _select(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isLoading = context.select<TransactionsRepository, bool>(
      (repo) => repo.isLoading,
    );
    final isOffline = context.select<TransactionsRepository, bool>(
      (repo) => repo.isOffline,
    );

    final screens = [
      DashboardScreen(
        onSeeAllTransactions: () => _select(1),
        onSeeAllSpending: () => _select(2),
      ),
      const TransactionsScreen(),
      const AnalyticsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
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
                : IndexedStack(index: _selectedIndex, children: screens),
          ),
        ],
      ),
      floatingActionButton: SizedBox.square(
        dimension: 64,
        child: FloatingActionButton(
          tooltip: 'Add transaction',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTransactionScreen(),
            ),
          ),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      floatingActionButtonLocation: const _RaisedCenterDockedFabLocation(),
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
                const SizedBox(width: 72),
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
    );
  }
}

/// Centers the add button on the bar's top edge, lifted so most of it sits
/// above the bar.
class _RaisedCenterDockedFabLocation extends FloatingActionButtonLocation {
  const _RaisedCenterDockedFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final x =
        (geometry.scaffoldSize.width -
            geometry.floatingActionButtonSize.width) /
        2;
    final y =
        geometry.contentBottom -
        geometry.floatingActionButtonSize.height * 0.62;
    return Offset(x, y);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
