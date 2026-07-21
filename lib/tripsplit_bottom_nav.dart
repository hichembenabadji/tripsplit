import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

enum TripSplitBottomNavTab { calculator, trips, profile }

class TripSplitBottomNav extends StatelessWidget {
  const TripSplitBottomNav({
    super.key,
    required this.activeTab,
    required this.backgroundColor,
    required this.separatorColor,
    required this.activeFillColor,
    required this.activeTextColor,
    required this.inactiveTextColor,
    this.onCalculatorTap,
    this.onTripsTap,
    this.onProfileTap,
  });

  final TripSplitBottomNavTab activeTab;
  final Color backgroundColor;
  final Color separatorColor;
  final Color activeFillColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final VoidCallback? onCalculatorTap;
  final VoidCallback? onTripsTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final SharedColorTokens shared = Theme.of(
      context,
    ).extension<AppColors>()!.shared;

    return Material(
      color: backgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TripSplitBottomNavSeparator(color: separatorColor),
            ),
            Container(
              color: shared.navBackground,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _TripSplitBottomNavItem(
                        key: const ValueKey<String>('bottom_nav_calculator'),
                        icon: Icons.calculate_outlined,
                        label: 'Calculator',
                        isActive: activeTab == TripSplitBottomNavTab.calculator,
                        activeFillColor: activeFillColor,
                        activeTextColor: activeTextColor,
                        inactiveTextColor: inactiveTextColor,
                        onTap: activeTab == TripSplitBottomNavTab.calculator
                            ? null
                            : onCalculatorTap,
                      ),
                      _TripSplitBottomNavItem(
                        key: const ValueKey<String>('bottom_nav_trips'),
                        icon: Icons.card_travel_rounded,
                        label: 'Trips',
                        isActive: activeTab == TripSplitBottomNavTab.trips,
                        activeFillColor: activeFillColor,
                        activeTextColor: activeTextColor,
                        inactiveTextColor: inactiveTextColor,
                        onTap: activeTab == TripSplitBottomNavTab.trips
                            ? null
                            : onTripsTap,
                      ),
                      _TripSplitBottomNavItem(
                        key: const ValueKey<String>('bottom_nav_profile'),
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                        isActive: activeTab == TripSplitBottomNavTab.profile,
                        activeFillColor: activeFillColor,
                        activeTextColor: activeTextColor,
                        inactiveTextColor: inactiveTextColor,
                        onTap: activeTab == TripSplitBottomNavTab.profile
                            ? null
                            : onProfileTap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripSplitBottomNavItem extends StatelessWidget {
  const _TripSplitBottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeFillColor,
    required this.activeTextColor,
    required this.inactiveTextColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeFillColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SharedColorTokens shared = Theme.of(
      context,
    ).extension<AppColors>()!.shared;
    final Color textColor = isActive ? activeTextColor : inactiveTextColor;

    return Material(
      color: shared.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isActive ? 20 : 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isActive ? activeFillColor : shared.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: textColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripSplitBottomNavSeparator extends StatelessWidget {
  const _TripSplitBottomNavSeparator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    const double dashWidth = 4;
    const double gapWidth = 3;
    const double thickness = 1;

    return SizedBox(
      height: thickness,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int dashCount = (constraints.maxWidth / (dashWidth + gapWidth))
              .floor();

          return Row(
            children: List<Widget>.generate(dashCount, (int index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == dashCount - 1 ? 0 : gapWidth,
                ),
                child: SizedBox(
                  width: dashWidth,
                  height: thickness,
                  child: DecoratedBox(decoration: BoxDecoration(color: color)),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
