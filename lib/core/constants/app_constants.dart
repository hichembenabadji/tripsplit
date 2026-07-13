import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const appName = 'TripSplit';
  static const defaultCurrencyCode = 'EUR';
}

class AppNavigationItem {
  const AppNavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

const primaryNavigationItems = <AppNavigationItem>[
  AppNavigationItem(
    label: 'Calculator',
    icon: Icons.calculate_outlined,
    activeIcon: Icons.calculate_rounded,
  ),
  AppNavigationItem(
    label: 'Trips',
    icon: Icons.luggage_outlined,
    activeIcon: Icons.luggage_rounded,
  ),
  AppNavigationItem(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
];
