import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/user.dart';

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({required this.user, super.key, this.size = 36});

  final User user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size.r;

    return Container(
      width: resolvedSize,
      height: resolvedSize,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.creamStrong, width: 2.r),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          user.initials,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primaryDark,
            fontSize: (size / 3.3).sp,
          ),
        ),
      ),
    );
  }
}
