import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/user.dart';
import 'avatar_badge.dart';

class AvatarStack extends StatelessWidget {
  const AvatarStack({
    required this.users,
    super.key,
    this.avatarSize = 36,
    this.maxVisible = 4,
  });

  final List<User> users;
  final double avatarSize;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleUsers = users.take(maxVisible).toList();
    final overflowCount = users.length - visibleUsers.length;
    final itemCount = overflowCount > 0
        ? visibleUsers.length + 1
        : visibleUsers.length;
    final overlap = avatarSize * 0.62;
    final width = avatarSize + (itemCount - 1) * overlap;

    return SizedBox(
      width: width,
      height: avatarSize,
      child: Stack(
        children: <Widget>[
          for (var index = 0; index < visibleUsers.length; index++)
            Positioned(
              left: index * overlap,
              child: AvatarBadge(user: visibleUsers[index], size: avatarSize),
            ),
          if (overflowCount > 0)
            Positioned(
              left: visibleUsers.length * overlap,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.creamStrong, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$overflowCount',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.white,
                    fontSize: avatarSize / 3.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
