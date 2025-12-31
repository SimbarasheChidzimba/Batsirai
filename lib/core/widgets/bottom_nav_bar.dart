import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/app_colors.dart';

class ScaffoldWithBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          NavigationDestination(
            icon: PhosphorIcon(PhosphorIcons.house()),
            selectedIcon: PhosphorIcon(
              PhosphorIcons.house(PhosphorIconsStyle.fill),
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: PhosphorIcon(PhosphorIcons.forkKnife()),
            selectedIcon: PhosphorIcon(
              PhosphorIcons.forkKnife(PhosphorIconsStyle.fill),
            ),
            label: 'Restaurants',
          ),
          NavigationDestination(
            icon: PhosphorIcon(PhosphorIcons.ticket()),
            selectedIcon: PhosphorIcon(
              PhosphorIcons.ticket(PhosphorIconsStyle.fill),
            ),
            label: 'Events',
          ),
          NavigationDestination(
            icon: PhosphorIcon(PhosphorIcons.crownSimple()),
            selectedIcon: PhosphorIcon(
              PhosphorIcons.crownSimple(PhosphorIconsStyle.fill),
            ),
            label: 'Premium',
          ),
          NavigationDestination(
            icon: PhosphorIcon(PhosphorIcons.user()),
            selectedIcon: PhosphorIcon(
              PhosphorIcons.user(PhosphorIconsStyle.fill),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
