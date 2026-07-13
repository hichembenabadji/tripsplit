import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/user.dart';

class AvatarBadge extends StatelessWidget {
  const AvatarBadge({required this.user, super.key, this.size = 36});

  final User user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.creamStrong, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        user.initials,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.primaryDark,
          fontSize: size / 3.3,
        ),
      ),
    );
  }
}
