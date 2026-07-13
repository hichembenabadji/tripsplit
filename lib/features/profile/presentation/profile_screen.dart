import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/repositories/users_repository.dart';
import '../../../shared/widgets/app_screen.dart';
import '../../../shared/widgets/avatar_badge.dart';
import '../widgets/profile_preference_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return AppScreen(
      title: 'Profile',
      subtitle: 'Shared preference tiles and summary patterns are ready.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(color: AppColors.outline),
            ),
            child: Column(
              children: <Widget>[
                AvatarBadge(user: currentUser, size: 72),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  currentUser.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  currentUser.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const ProfilePreferenceTile(
            icon: Icons.euro_rounded,
            title: 'Default currency',
            value: 'EUR',
          ),
          const SizedBox(height: AppSpacing.lg),
          const ProfilePreferenceTile(
            icon: Icons.language_rounded,
            title: 'Language',
            value: 'English',
          ),
          const SizedBox(height: AppSpacing.lg),
          const ProfilePreferenceTile(
            icon: Icons.notifications_active_outlined,
            title: 'Expense notifications',
            toggleValue: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          const ProfilePreferenceTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Face ID / Touch ID',
            toggleValue: true,
          ),
        ],
      ),
    );
  }
}
