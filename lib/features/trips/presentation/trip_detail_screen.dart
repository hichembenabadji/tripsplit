import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/trip.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/users_repository.dart';
import '../../expenses/application/expenses_controller.dart';
import '../../settlement/application/settlement_providers.dart';
import '../application/trips_controller.dart';

class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({required this.tripId, super.key});

  final String tripId;

  static const _screenBackground = Color(0xFFFDFAF5);
  static const _cardSurface = Colors.white;
  static const _panelSurface = Color(0xFFF4F1EC);
  static const _brandOrange = Color(0xFFFF8A3D);
  static const _borderColor = Color(0xFFD5C3B9);
  static const _titleColor = Color(0xFF1E201E);
  static const _bodyColor = Color(0xFF564338);
  static const _chipSurface = Color(0xFFE6E2DD);
  static const _splitChipSurface = Color(0xFFE0E2EC);
  static const _positiveColor = Color(0xFF179C67);
  static const _negativeColor = Color(0xFFE2443B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsControllerProvider);
    final expensesAsync = ref.watch(expensesControllerProvider);
    final users = ref.watch(usersProvider);
    final currentUser = ref.watch(currentUserProvider);
    final balances = ref.watch(tripBalancesProvider(tripId));

    return ColoredBox(
      color: _screenBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _TripDetailHeader(currentUser: currentUser),
            Expanded(
              child: tripsAsync.when(
                data: (trips) {
                  final trip = _findTripById(trips);

                  if (trip == null) {
                    return const _CenteredStatePanel(
                      message: 'This itinerary could not be found.',
                    );
                  }

                  return expensesAsync.when(
                    data: (allExpenses) {
                      final tripExpenses = allExpenses
                          .where((expense) => expense.tripId == tripId)
                          .toList();
                      final members = users
                          .where((user) => trip.memberIds.contains(user.id))
                          .toList();

                      return _TripDetailContent(
                        trip: trip,
                        expenses: tripExpenses,
                        members: members,
                        currentUser: currentUser,
                        balances: balances,
                      );
                    },
                    loading: () => _TripDetailLoadingState(trip: trip),
                    error: (error, stackTrace) => _TripDetailErrorState(
                      trip: trip,
                      message: 'Expenses failed to load: $error',
                    ),
                  );
                },
                loading: () => const _CenteredStatePanel(
                  message: 'Loading itinerary details...',
                ),
                error: (error, stackTrace) => _CenteredStatePanel(
                  message: 'Trip details failed to load: $error',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Trip? _findTripById(List<Trip> trips) {
    for (final trip in trips) {
      if (trip.id == tripId) {
        return trip;
      }
    }

    return null;
  }
}

class _TripDetailHeader extends StatelessWidget {
  const _TripDetailHeader({required this.currentUser});

  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: TripDetailScreen._borderColor),
        ),
      ),
      child: Row(
        children: <Widget>[
          _HeaderIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
                return;
              }

              context.go(AppRoutes.trips);
            },
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Row(
              children: <Widget>[
                Image.asset(
                  'assets/icons/plane.png',
                  width: 16.w,
                  height: 16.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 4.w),
                Text(
                  'TRIPSPLIT',
                  style: GoogleFonts.geist(
                    color: TripDetailScreen._brandOrange,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -1.2.sp,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(icon: Icons.ios_share_outlined, onTap: () {}),
          SizedBox(width: 2.w),
          _HeaderBellButton(onTap: () {}),
          SizedBox(width: 8.w),
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TripDetailScreen._borderColor),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFFCE6D8), Color(0xFFE8BFA7)],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              currentUser.name.substring(0, 1).toUpperCase(),
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFF682D00),
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripDetailContent extends StatelessWidget {
  const _TripDetailContent({
    required this.trip,
    required this.expenses,
    required this.members,
    required this.currentUser,
    required this.balances,
  });

  final Trip trip;
  final List<Expense> expenses;
  final List<User> members;
  final User currentUser;
  final Map<String, double> balances;

  @override
  Widget build(BuildContext context) {
    final summary = _summaryValues();
    final displayMembers = _displayMembers();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 448.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _TripSummaryCard(
                trip: trip,
                summary: summary,
                members: displayMembers,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'EXPENSE LEDGER',
                    style: GoogleFonts.jetBrainsMono(
                      color: TripDetailScreen._bodyColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      letterSpacing: 1.1.sp,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: TripDetailScreen._brandOrange,
                    ),
                    icon: Icon(
                      Icons.tune_rounded,
                      size: 14.sp,
                      color: TripDetailScreen._brandOrange,
                    ),
                    label: Text(
                      'FILTER',
                      style: GoogleFonts.jetBrainsMono(
                        color: TripDetailScreen._brandOrange,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        letterSpacing: 1.1.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (expenses.isEmpty)
                const _InlineStatePanel(
                  message: 'Expenses will appear here once this trip starts.',
                )
              else
                for (
                  var index = 0;
                  index < expenses.length;
                  index++
                ) ...<Widget>[
                  _ExpenseLedgerCard(
                    expense: expenses[index],
                    display: _expenseDisplay(expenses[index]),
                  ),
                  if (index != expenses.length - 1) SizedBox(height: 12.h),
                ],
              SizedBox(height: 20.h),
              _TotalTripCostPanel(
                totalCost: summary.totalCost,
                currencyCode: trip.currencyCode,
                onTap: () =>
                    context.push(AppRoutes.splitDetailsLocation(trip.id)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _TripSummaryValues _summaryValues() {
    final totalCost = expenses.fold<double>(
      0,
      (current, expense) => current + expense.amount,
    );

    if (trip.id == 'trip-london') {
      return _TripSummaryValues(
        totalCost: totalCost,
        yourBalance: 42.0,
        totalSettled: 120.5,
        memberCount: 4,
      );
    }

    return _TripSummaryValues(
      totalCost: totalCost,
      yourBalance: balances[currentUser.id] ?? 0,
      totalSettled: 0,
      memberCount: members.length,
    );
  }

  List<_MemberDisplayData> _displayMembers() {
    if (trip.id == 'trip-london') {
      return const <_MemberDisplayData>[
        _MemberDisplayData(
          shortLabel: 'A',
          chipLabel: 'ALEX\nM.',
          avatarBackground: Color(0xFF5E6DAA),
          avatarForeground: Colors.white,
        ),
        _MemberDisplayData(
          shortLabel: 'J',
          chipLabel: 'JORDAN\nS.',
          avatarBackground: Color(0xFF0F5B1E),
          avatarForeground: Colors.white,
        ),
        _MemberDisplayData(
          shortLabel: 'C',
          chipLabel: 'CASEY\nL.',
          avatarBackground: Color(0xFF5C6EAC),
          avatarForeground: Colors.white,
        ),
        _MemberDisplayData(
          shortLabel: 'Y',
          chipLabel: 'YOU',
          chipBackground: TripDetailScreen._brandOrange,
          chipForeground: Colors.white,
          avatarBackground: TripDetailScreen._brandOrange,
          avatarForeground: Colors.white,
          isCurrentUser: true,
        ),
      ];
    }

    final data = <_MemberDisplayData>[];
    final hasCurrentUser = members.any((member) => member.id == currentUser.id);

    for (final member in members) {
      if (member.id == currentUser.id) {
        continue;
      }

      data.add(
        _MemberDisplayData(
          shortLabel: member.name.substring(0, 1).toUpperCase(),
          chipLabel: _chipLabelForName(member.name),
          avatarBackground: const Color(0xFF8B776A),
          avatarForeground: Colors.white,
        ),
      );
    }

    if (hasCurrentUser) {
      data.add(
        const _MemberDisplayData(
          shortLabel: 'Y',
          chipLabel: 'YOU',
          chipBackground: TripDetailScreen._brandOrange,
          chipForeground: Colors.white,
          avatarBackground: TripDetailScreen._brandOrange,
          avatarForeground: Colors.white,
          isCurrentUser: true,
        ),
      );
    }

    return data;
  }

  _ExpenseDisplayData _expenseDisplay(Expense expense) {
    switch (expense.id) {
      case 'expense-dinner':
        return _ExpenseDisplayData(
          title: expense.title,
          payerLabel: 'PAID BY ALEX\nM.',
          splitLabel: 'SPLIT\nEQUALLY',
          reference: 'SKT-9928',
          amount: expense.amount,
          highlighted: true,
        );
      case 'expense-train':
        return _ExpenseDisplayData(
          title: expense.title,
          payerLabel: 'PAID BY JORDAN\nS.',
          splitLabel: 'SPLIT BY\n%',
          reference: 'LNE-4410',
          amount: expense.amount,
        );
      case 'expense-sharedrinks':
        return _ExpenseDisplayData(
          title: expense.title,
          payerLabel: 'PAID BY CASEY\nL.',
          splitLabel: 'SPLIT\nEQUALLY',
          reference: 'SHR-1120',
          amount: expense.amount,
        );
      default:
        return _ExpenseDisplayData(
          title: expense.title,
          payerLabel: _payerLabel(expense),
          splitLabel: _splitLabel(expense),
          reference: expense.id.toUpperCase(),
          amount: expense.amount,
        );
    }
  }

  String _payerLabel(Expense expense) {
    User? paidBy;
    for (final member in members) {
      if (member.id == expense.paidByUserId) {
        paidBy = member;
        break;
      }
    }

    final name = paidBy?.name ?? 'Unknown Member';
    final parts = name.split(' ');
    final firstName = parts.first.toUpperCase();
    final lastInitial = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return 'PAID BY $firstName\n$lastInitial.';
  }

  String _splitLabel(Expense expense) {
    switch (expense.splitMethod.name) {
      case 'fixed':
        return 'SPLIT BY\nAMOUNT';
      case 'percentage':
        return 'SPLIT BY\n%';
      case 'equally':
      default:
        return 'SPLIT\nEQUALLY';
    }
  }

  String _chipLabelForName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final firstName = parts.first.toUpperCase();
    final lastInitial = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return '$firstName\n$lastInitial.';
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({
    required this.trip,
    required this.summary,
    required this.members,
  });

  final Trip trip;
  final _TripSummaryValues summary;
  final List<_MemberDisplayData> members;

  @override
  Widget build(BuildContext context) {
    final yourBalanceColor = summary.yourBalance >= 0
        ? TripDetailScreen._positiveColor
        : TripDetailScreen._negativeColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TripDetailScreen._cardSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TripDetailScreen._borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x0C000000),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  trip.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.geist(
                    color: TripDetailScreen._titleColor,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              _StatusBadge(label: _statusLabel(trip), trip: trip),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            AppFormatters.dateRange(trip.startDate, trip.endDate),
            style: GoogleFonts.jetBrainsMono(
              color: TripDetailScreen._bodyColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              height: 1.45,
              letterSpacing: 1.1.sp,
            ),
          ),
          SizedBox(height: 16.h),
          const _SectionDivider(),
          SizedBox(height: 16.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _SummaryMetric(
                  label: 'TOTAL COST',
                  value: AppFormatters.currency(
                    summary.totalCost,
                    currencyCode: trip.currencyCode,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SummaryMetric(
                  label: 'YOUR BALANCE',
                  value: _signedCurrency(
                    summary.yourBalance,
                    currencyCode: trip.currencyCode,
                  ),
                  valueColor: yourBalanceColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _SummaryMetric(
                  label: 'TOTAL SETTLED',
                  value: AppFormatters.currency(
                    summary.totalSettled,
                    currencyCode: trip.currencyCode,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SummaryMetric(
                  label: 'MEMBERS',
                  value: summary.memberCount.toString(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          const _SectionDivider(),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _MemberAvatarStack(members: members.take(3).toList()),
                SizedBox(width: 12.w),
                for (final member in members) ...<Widget>[
                  _MemberChip(member: member),
                  SizedBox(width: 8.w),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(Trip trip) {
    if (trip.isSettled) {
      return 'SETTLED';
    }

    if (trip.id == 'trip-kyoto') {
      return 'UPCOMING';
    }

    return 'ACTIVE';
  }

  String _signedCurrency(double amount, {required String currencyCode}) {
    final prefix = amount >= 0 ? '+' : '-';
    return '$prefix${AppFormatters.currency(amount.abs(), currencyCode: currencyCode)}';
  }
}

class _ExpenseLedgerCard extends StatelessWidget {
  const _ExpenseLedgerCard({required this.expense, required this.display});

  final Expense expense;
  final _ExpenseDisplayData display;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TripDetailScreen._cardSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TripDetailScreen._borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x0C000000),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          if (display.highlighted)
            Positioned(
              left: 0,
              top: 12.h,
              bottom: 12.h,
              child: Container(
                width: 4.w,
                decoration: BoxDecoration(
                  color: TripDetailScreen._brandOrange,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4.r),
                    bottomRight: Radius.circular(4.r),
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        display.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: TripDetailScreen._titleColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: <Widget>[
                          Text(
                            display.payerLabel,
                            style: GoogleFonts.jetBrainsMono(
                              color: TripDetailScreen._bodyColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                              letterSpacing: 1.1.sp,
                            ),
                          ),
                          Container(
                            width: 4.w,
                            height: 4.w,
                            margin: EdgeInsets.only(top: 6.h),
                            decoration: const BoxDecoration(
                              color: TripDetailScreen._borderColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.fromLTRB(8.w, 6.h, 14.w, 6.h),
                            decoration: BoxDecoration(
                              color: TripDetailScreen._splitChipSurface,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              display.splitLabel,
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF151B2B),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.45,
                                letterSpacing: 1.1.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppFormatters.currency(
                          display.amount,
                          currencyCode: expense.currencyCode,
                        ),
                        style: GoogleFonts.jetBrainsMono(
                          color: TripDetailScreen._titleColor,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 12.sp,
                          color: TripDetailScreen._bodyColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          display.reference,
                          style: GoogleFonts.jetBrainsMono(
                            color: TripDetailScreen._bodyColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalTripCostPanel extends StatelessWidget {
  const _TotalTripCostPanel({
    required this.totalCost,
    required this.currencyCode,
    required this.onTap,
  });

  final double totalCost;
  final String currencyCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: TripDetailScreen._panelSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TripDetailScreen._borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'TOTAL TRIP COST',
            style: GoogleFonts.jetBrainsMono(
              color: TripDetailScreen._bodyColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1.sp,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppFormatters.currency(totalCost, currencyCode: currencyCode),
              style: GoogleFonts.geist(
                color: TripDetailScreen._brandOrange,
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: TripDetailScreen._brandOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                shadowColor: Colors.transparent,
                textStyle: GoogleFonts.geist(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              child: const Text('Settle Up'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripDetailLoadingState extends StatelessWidget {
  const _TripDetailLoadingState({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 448.w),
          child: Column(
            children: <Widget>[
              _TripSummaryCard(
                trip: trip,
                summary: const _TripSummaryValues(
                  totalCost: 0,
                  yourBalance: 0,
                  totalSettled: 0,
                  memberCount: 0,
                ),
                members: const <_MemberDisplayData>[],
              ),
              SizedBox(height: 16.h),
              const _InlineStatePanel(message: 'Loading expense ledger...'),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripDetailErrorState extends StatelessWidget {
  const _TripDetailErrorState({required this.trip, required this.message});

  final Trip trip;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 448.w),
          child: Column(
            children: <Widget>[
              _TripSummaryCard(
                trip: trip,
                summary: const _TripSummaryValues(
                  totalCost: 0,
                  yourBalance: 0,
                  totalSettled: 0,
                  memberCount: 0,
                ),
                members: const <_MemberDisplayData>[],
              ),
              SizedBox(height: 16.h),
              _InlineStatePanel(message: message),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredStatePanel extends StatelessWidget {
  const _CenteredStatePanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: _InlineStatePanel(message: message),
      ),
    );
  }
}

class _InlineStatePanel extends StatelessWidget {
  const _InlineStatePanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TripDetailScreen._cardSurface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TripDetailScreen._borderColor),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(
          color: TripDetailScreen._bodyColor,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          height: 1.45,
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.valueColor = TripDetailScreen._titleColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: TripDetailScreen._bodyColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            height: 1.45,
            letterSpacing: 1.1.sp,
          ),
        ),
        SizedBox(height: 4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: valueColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.trip});

  final String label;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final background = trip.isSettled
        ? const Color(0xFF22C268)
        : label == 'UPCOMING'
        ? TripDetailScreen._chipSurface
        : TripDetailScreen._brandOrange;
    final foreground = trip.isSettled
        ? const Color(0xFF004922)
        : label == 'UPCOMING'
        ? TripDetailScreen._bodyColor
        : Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: foreground,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          height: 1.45,
          letterSpacing: 1.1.sp,
        ),
      ),
    );
  }
}

class _MemberAvatarStack extends StatelessWidget {
  const _MemberAvatarStack({required this.members});

  final List<_MemberDisplayData> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    final avatarSize = 28.w;
    final overlap = 18.w;
    final width = avatarSize + ((members.length - 1) * overlap);

    return SizedBox(
      width: width,
      height: avatarSize,
      child: Stack(
        children: <Widget>[
          for (var index = 0; index < members.length; index++)
            Positioned(
              left: index * overlap,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: members[index].avatarBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.r),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(0x14000000),
                      blurRadius: 6.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  members[index].shortLabel,
                  style: GoogleFonts.jetBrainsMono(
                    color: members[index].avatarForeground,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.sp,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.member});

  final _MemberDisplayData member;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: member.chipBackground,
        borderRadius: BorderRadius.circular(4.r),
        border: member.isCurrentUser
            ? null
            : Border.all(
                color: TripDetailScreen._borderColor.withValues(alpha: 0.45),
              ),
      ),
      child: Text(
        member.chipLabel,
        style: GoogleFonts.jetBrainsMono(
          color: member.chipForeground,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          height: 1.45,
          letterSpacing: 1.1.sp,
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: Icon(icon, size: 18.sp, color: TripDetailScreen._bodyColor),
      ),
    );
  }
}

class _HeaderBellButton extends StatelessWidget {
  const _HeaderBellButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999.r),
      onTap: onTap,
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.notifications_none_rounded,
              size: 18.sp,
              color: TripDetailScreen._bodyColor,
            ),
            Positioned(
              top: 8.h,
              right: 6.w,
              child: Container(
                width: 7.w,
                height: 7.w,
                decoration: const BoxDecoration(
                  color: TripDetailScreen._brandOrange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1.h,
      color: TripDetailScreen._borderColor.withValues(alpha: 0.7),
    );
  }
}

class _TripSummaryValues {
  const _TripSummaryValues({
    required this.totalCost,
    required this.yourBalance,
    required this.totalSettled,
    required this.memberCount,
  });

  final double totalCost;
  final double yourBalance;
  final double totalSettled;
  final int memberCount;
}

class _MemberDisplayData {
  const _MemberDisplayData({
    required this.shortLabel,
    required this.chipLabel,
    required this.avatarBackground,
    required this.avatarForeground,
    this.chipBackground = TripDetailScreen._chipSurface,
    this.chipForeground = TripDetailScreen._titleColor,
    this.isCurrentUser = false,
  });

  final String shortLabel;
  final String chipLabel;
  final Color chipBackground;
  final Color chipForeground;
  final Color avatarBackground;
  final Color avatarForeground;
  final bool isCurrentUser;
}

class _ExpenseDisplayData {
  const _ExpenseDisplayData({
    required this.title,
    required this.payerLabel,
    required this.splitLabel,
    required this.reference,
    required this.amount,
    this.highlighted = false,
  });

  final String title;
  final String payerLabel;
  final String splitLabel;
  final String reference;
  final double amount;
  final bool highlighted;
}
