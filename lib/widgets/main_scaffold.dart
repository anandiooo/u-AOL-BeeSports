import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:beesports/app/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/lobbies')) return 1;
    if (location.startsWith('/wallet')) return 2;
    if (location.startsWith('/leaderboard')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    HapticFeedback.selectionClick();
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/lobbies');
        break;
      case 2:
        context.go('/wallet');
        break;
      case 3:
        context.go('/leaderboard');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: child,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBar,
          border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(index: 0, selectedIndex: selectedIndex, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', onTap: () => _onItemTapped(0, context)),
                _NavItem(index: 1, selectedIndex: selectedIndex, icon: Icons.sports_soccer_outlined, activeIcon: Icons.sports_soccer, label: 'Lobbies', onTap: () => _onItemTapped(1, context)),
                _NavItem(index: 2, selectedIndex: selectedIndex, icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Wallet', onTap: () => _onItemTapped(2, context)),
                _NavItem(index: 3, selectedIndex: selectedIndex, icon: Icons.leaderboard_outlined, activeIcon: Icons.leaderboard_rounded, label: 'Rank', onTap: () => _onItemTapped(3, context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.index, required this.selectedIndex, required this.icon, required this.activeIcon, required this.label, required this.onTap});

  bool get isSelected => index == selectedIndex;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isSelected ? AppColors.navSelected : AppColors.navUnselected;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.navSelected.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navSelected.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(isSelected ? activeIcon : icon, key: ValueKey(isSelected), size: 24, color: effectiveColor),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: effectiveColor),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
