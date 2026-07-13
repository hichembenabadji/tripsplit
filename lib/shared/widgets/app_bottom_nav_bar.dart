import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg.w,
          0,
          AppSpacing.lg.w,
          AppSpacing.lg.h,
        ),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm.w),
          decoration: BoxDecoration(
            color: AppColors.creamStrong,
            borderRadius: BorderRadius.circular(AppRadii.xl.r),
            border: Border.all(color: AppColors.outline),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 24.r,
                offset: Offset(0, 12.h),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              for (
                var index = 0;
                index < primaryNavigationItems.length;
                index++
              )
                Expanded(
                  child: _NavBarItem(
                    item: primaryNavigationItems[index],
                    selected: index == currentIndex,
                    onTap: () => onTap(index),
                  ),
                ),
            ],
          ),
        ),
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
    final foreground = selected ? AppColors.white : AppColors.mutedInk;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.md.h,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.lg.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                selected ? item.activeIcon : item.icon,
                color: foreground,
                size: 20.sp,
              ),
              SizedBox(height: AppSpacing.sm.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
