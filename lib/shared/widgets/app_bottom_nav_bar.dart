import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static double height(BuildContext context) {
    return 84.h + MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, bottomInset + 16.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFF564338))),
      ),
      child: Row(
        children: <Widget>[
          for (var index = 0; index < primaryNavigationItems.length; index++)
            Expanded(
              child: _NavBarItem(
                item: primaryNavigationItems[index],
                selected: index == currentIndex,
                onTap: () => onTap(index),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF682D00);
    const inactiveColor = Color(0xFF404758);

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFF8A3D) : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                selected ? item.activeIcon : item.icon,
                size: 18.sp,
                color: selected ? activeColor : inactiveColor,
              ),
              SizedBox(height: 4.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  style: GoogleFonts.jetBrainsMono(
                    color: selected ? activeColor : inactiveColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    letterSpacing: 1.1.sp,
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
