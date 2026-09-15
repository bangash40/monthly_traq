import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:monthly_traq/features/analytics/analytics_screen.dart';
import 'package:monthly_traq/features/dashboard/dashboard_screen.dart';
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

  void _goToTransactions() => setState(() => _selectedIndex = 1);

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<TransactionsRepository, bool>(
      (repo) => repo.isLoading,
    );

    final screens = [
      DashboardScreen(onSeeAllTransactions: _goToTransactions),
      const TransactionsScreen(),
      const AnalyticsScreen(),
    ];

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(index: _selectedIndex, children: screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
