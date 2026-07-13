import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/navigation/app_routes.dart';
import 'app_bottom_nav_bar.dart';

class TripsplitShellScaffold extends StatelessWidget {
  const TripsplitShellScaffold({
    required this.navigationShell,
    required this.currentLocation,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final navHeight = AppBottomNavBar.height(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final detailTripId = _activeDetailTripId();
    final showTripsFab =
        currentLocation == AppRoutes.trips || detailTripId != null;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(bottom: navHeight, child: navigationShell),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          ),
          if (showTripsFab)
            Positioned(
              right: 16.w,
              bottom: bottomInset + 50.h,
              child: _AddTripButton(
                onTap: () {
                  if (detailTripId != null) {
                    context.push(AppRoutes.addExpenseLocation(detailTripId));
                    return;
                  }

                  context.push('${AppRoutes.trips}/${AppRoutes.createTrip}');
                },
              ),
            ),
        ],
      ),
    );
  }

  String? _activeDetailTripId() {
    final detailPattern = RegExp(
      '^${RegExp.escape(AppRoutes.trips)}/([^/]+)\$',
    );
    final match = detailPattern.firstMatch(currentLocation);

    if (match == null) {
      return null;
    }

    return match.group(1);
  }
}

class _AddTripButton extends StatelessWidget {
  const _AddTripButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: onTap,
        child: Ink(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFF8A3D),
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x19000000),
                blurRadius: 15.r,
                offset: Offset(0, 10.h),
                spreadRadius: -3.r,
              ),
              BoxShadow(
                color: const Color(0x19000000),
                blurRadius: 6.r,
                offset: Offset(0, 4.h),
                spreadRadius: -4.r,
              ),
            ],
          ),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28.sp),
        ),
      ),
    );
  }
}
