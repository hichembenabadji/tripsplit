import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/trip.dart';
import '../../data/models/user.dart';
import 'avatar_stack.dart';
import 'status_pill.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    required this.trip,
    required this.members,
    super.key,
    this.onTap,
  });

  final Trip trip;
  final List<User> members;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tone = trip.isSettled
        ? StatusPillTone.settled
        : StatusPillTone.active;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          trip.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${trip.destination} · ${AppFormatters.dateRange(trip.startDate, trip.endDate)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  StatusPill(
                    label: trip.isSettled ? 'Settled' : 'Active',
                    tone: tone,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: <Widget>[
                  AvatarStack(users: members),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        'Trip total',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppFormatters.currency(
                          trip.totalAmount,
                          currencyCode: trip.currencyCode,
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
