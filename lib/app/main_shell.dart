import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/app/palette.dart';
import 'package:monthly_traq/app/theme.dart';
import 'package:monthly_traq/features/analytics/analytics_screen.dart';
import 'package:monthly_traq/features/dashboard/dashboard_screen.dart';
import 'package:monthly_traq/features/transactions/add_edit_transaction_screen.dart';
import 'package:monthly_traq/features/settings/settings_screen.dart';
import 'package:monthly_traq/features/transactions/transactions_screen.dart';
import 'package:monthly_traq/services/transactions_repository.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _goToTransactions() => setState(() => _selectedIndex = 1);

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<TransactionsRepository, bool>(
      (repo) => repo.isLoading,
    );
    final isOffline = context.select<TransactionsRepository, bool>(
      (repo) => repo.isOffline,
    );

    final screens = [
      DashboardScreen(onSeeAllTransactions: _goToTransactions),
      const TransactionsScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
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
                    color: AppPalette.warning,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Text(
                      "You're offline — showing cached data",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: const _SunkenCenterDockedFabLocation(),
      bottomNavigationBar: BottomAppBar(
        // No notch shape — the button sits flush on top of a flat bar,
        // rather than being recessed into a cutout.
        shape: null,
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                Expanded(
                  child: _NavButton(
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard,
                    label: 'Dashboard',
                    isSelected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                ),
                Expanded(
                  child: _NavButton(
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long,
                    label: 'Transactions',
                    isSelected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ),
                const SizedBox(width: 56),
                Expanded(
                  child: _NavButton(
                    icon: Icons.pie_chart_outline,
                    selectedIcon: Icons.pie_chart,
                    label: 'Analytics',
                    isSelected: _selectedIndex == 2,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                ),
                Expanded(
                  child: _NavButton(
                    icon: Icons.person_outline,
                    selectedIcon: Icons.person,
                    label: 'Profile',
                    isSelected: _selectedIndex == 3,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Like [FloatingActionButtonLocation.centerDocked], but sinks the button
/// further down so most of it sits within the bottom bar rather than the
/// standard 50/50 split above/below the bar's top edge.
class _SunkenCenterDockedFabLocation extends FloatingActionButtonLocation {
  const _SunkenCenterDockedFabLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final fabX =
        (scaffoldGeometry.scaffoldSize.width -
            scaffoldGeometry.floatingActionButtonSize.width) /
        2.0;
    final fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    // Only a small cap of the button's height peeks above the bar's top edge.
    final fabY = scaffoldGeometry.contentBottom - fabHeight * 0.12;
    return Offset(fabX, fabY);
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? themeAccent(context)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
