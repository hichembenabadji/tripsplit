import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/expense.dart';
import '../../data/models/split_method.dart';
import '../../data/models/user.dart';
import 'status_pill.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    required this.expense,
    required this.paidBy,
    required this.participants,
    super.key,
    this.onTap,
  });

  final Expense expense;
  final User paidBy;
  final List<User> participants;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(AppRadii.md.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md.r),
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
                          expense.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Text(
                          'Paid by ${paidBy.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 104.w),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppFormatters.currency(
                          expense.amount,
                          currencyCode: expense.currencyCode,
                        ),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.primaryDark),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.lg.h),
              Row(
                children: <Widget>[
                  StatusPill(
                    label: expense.splitMethod.label,
                    tone: StatusPillTone.neutral,
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: Text(
                      '${participants.length} participants',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall,
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
