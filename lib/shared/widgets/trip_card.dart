import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      borderRadius: BorderRadius.circular(AppRadii.lg.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(AppSpacing.xl.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg.r),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Text(
                          '${trip.destination} - ${AppFormatters.dateRange(trip.startDate, trip.endDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  StatusPill(
                    label: trip.isSettled ? 'Settled' : 'Active',
                    tone: tone,
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xl.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  AvatarStack(users: members),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Trip total',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            AppFormatters.currency(
                              trip.totalAmount,
                              currencyCode: trip.currencyCode,
                            ),
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: AppColors.primaryDark),
                          ),
                        ),
                      ],
                    ),
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
