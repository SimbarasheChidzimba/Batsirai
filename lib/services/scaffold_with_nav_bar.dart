import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
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
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIcons.house()),
            selectedIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.forkKnife()),
            selectedIcon: Icon(PhosphorIcons.forkKnife(PhosphorIconsStyle.fill)),
            label: 'Restaurants',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.ticket()),
            selectedIcon: Icon(PhosphorIcons.ticket(PhosphorIconsStyle.fill)),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.user()),
            selectedIcon: Icon(PhosphorIcons.user(PhosphorIconsStyle.fill)),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
