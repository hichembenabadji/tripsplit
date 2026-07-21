import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'app_colors.dart';
import 'app_routes.dart';
import 'create_expense.dart';
import 'expense_details.dart';
import 'final_settle_up.dart';
import 'trip_store.dart';
import 'tripsplit_bottom_nav.dart';

final Map<String, NumberFormat> _tripDetailsCurrencyFormatters =
    <String, NumberFormat>{};

String _formatTripCurrency(
  double amount, {
  required String currencyCode,
  required String currencySymbol,
}) {
  final String formatterKey = '$currencyCode::$currencySymbol';
  final NumberFormat formatter =
      _tripDetailsCurrencyFormatters[formatterKey] ??= NumberFormat.currency(
        locale: 'en_US',
        name: currencyCode,
        symbol: currencySymbol,
        decimalDigits: 2,
      );

  return formatter.format(amount);
}

String _formatTripSignedCurrency(
  double amount, {
  required String currencyCode,
  required String currencySymbol,
}) {
  final String sign = amount >= 0 ? '+' : '-';
  return '$sign ${_formatTripCurrency(amount.abs(), currencyCode: currencyCode, currencySymbol: currencySymbol)}';
}

void _openCreateExpense(BuildContext context, String tripId) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'create_expense'),
      builder: (BuildContext context) => CreateExpenseScreen(tripId: tripId),
    ),
  );
}

void _openExpenseDetails(
  BuildContext context, {
  required String tripId,
  required String expenseReferenceCode,
}) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'expense_details'),
      builder: (BuildContext context) => ExpenseDetailsScreen(
        tripId: tripId,
        expenseReferenceCode: expenseReferenceCode,
      ),
    ),
  );
}

void _openCalculatorFromTripDetails(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.calculator);
}

void _openProfileFromTripDetails(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.profile);
}

void _openFinalSettleUp(BuildContext context, String tripId) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'final_settle_up'),
      builder: (BuildContext context) => FinalSettleUpScreen(tripId: tripId),
    ),
  );
}

extension _TripDetailsThemeAccess on BuildContext {
  AppColors get _appColors => Theme.of(this).extension<AppColors>()!;
  TripDetailsColorTokens get tripDetailsColors => _appColors.tripDetails;
  SharedColorTokens get sharedColors => _appColors.shared;
}

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    final TripSummary? trip = TripStoreScope.of(context).findTripById(tripId);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double horizontalPadding = screenSize.width < 360 ? 14 : 16;

    if (trip == null) {
      return Scaffold(
        backgroundColor: context.tripDetailsColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'This trip could not be found.',
                textAlign: TextAlign.center,
                style: GoogleFonts.geist(
                  color: context.tripDetailsColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: const ValueKey<String>('trip_details_screen'),
      backgroundColor: context.tripDetailsColors.background,
      bottomNavigationBar: TripSplitBottomNav(
        activeTab: TripSplitBottomNavTab.trips,
        backgroundColor: context.tripDetailsColors.background,
        separatorColor: context.tripDetailsColors.borderSoft,
        activeFillColor: context.tripDetailsColors.orange,
        activeTextColor: context.tripDetailsColors.orangeText,
        inactiveTextColor: context.tripDetailsColors.textSecondary,
        onCalculatorTap: () => _openCalculatorFromTripDetails(context),
        onProfileTap: () => _openProfileFromTripDetails(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: 4, bottom: 18),
        child: _AddExpenseButton(tripId: trip.id),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const _TripDetailsHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  144,
                ),
                children: <Widget>[
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _TripOverviewCard(trip: trip),
                          const SizedBox(height: 16),
                          _ParticipantsStrip(participants: trip.participants),
                          const SizedBox(height: 20),
                          const _SectionHeader(
                            title: 'EXPENSE LEDGER',
                            actionLabel: 'FILTER',
                          ),
                          const SizedBox(height: 12),
                          if (trip.expenses.isEmpty)
                            _EmptyLedgerCard(trip: trip)
                          else
                            ...trip.expenses.map((TripExpense expense) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ExpenseCard(
                                  trip: trip,
                                  expense: expense,
                                ),
                              );
                            }),
                          const SizedBox(height: 18),
                          _TripTotalCard(trip: trip),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripDetailsHeader extends StatelessWidget {
  const _TripDetailsHeader();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.tripDetailsColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: context.tripDetailsColors.orange,
                  ),
                ),
                Expanded(
                  child: Text(
                    'TRIPSPLIT',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.geist(
                      color: context.tripDetailsColors.orange,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -1.1,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 108,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      _HeaderIconButton(icon: Icons.share_outlined),
                      SizedBox(width: 2),
                      _NotificationButton(),
                      SizedBox(width: 2),
                      _HeaderAvatar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _DashedSeparator(),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: () {},
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        splashRadius: 18,
        icon: Icon(
          icon,
          size: 18,
          color: context.tripDetailsColors.textPrimary,
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          IconButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            splashRadius: 18,
            icon: Icon(
              Icons.notifications_none_rounded,
              size: 18,
              color: context.tripDetailsColors.textPrimary,
            ),
          ),
          Positioned(
            top: 4,
            right: 3,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: context.tripDetailsColors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.sharedColors.cardBackground,
        shape: BoxShape.circle,
        border: Border.all(color: context.tripDetailsColors.borderSoft),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              context.sharedColors.avatarGradientTop,
              context.sharedColors.avatarGradientBottom,
            ],
          ),
        ),
        child: Icon(
          Icons.person_rounded,
          size: 16,
          color: context.sharedColors.white,
        ),
      ),
    );
  }
}

class _TripOverviewCard extends StatelessWidget {
  const _TripOverviewCard({required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    final Color balanceColor = trip.yourBalance >= 0
        ? context.tripDetailsColors.green
        : context.tripDetailsColors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.sharedColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tripDetailsColors.border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.sharedColors.shadowSubtle,
            blurRadius: 2,
            offset: const Offset(0, 1),
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
                  style: GoogleFonts.geist(
                    color: context.tripDetailsColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(status: trip.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            trip.dateRangeLabel,
            style: GoogleFonts.inter(
              color: context.tripDetailsColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 18),
          const _DashedSeparator(),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricColumn(
                  label: 'TOTAL COST',
                  value: _formatTripCurrency(
                    trip.total,
                    currencyCode: trip.currencyCode,
                    currencySymbol: trip.currencySymbol,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricColumn(
                  label: 'YOUR BALANCE',
                  value: _formatTripSignedCurrency(
                    trip.yourBalance,
                    currencyCode: trip.currencyCode,
                    currencySymbol: trip.currencySymbol,
                  ),
                  valueColor: balanceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _MetricColumn(
                  label: 'TOTAL SETTLED',
                  value: _formatTripCurrency(
                    trip.totalSettled,
                    currencyCode: trip.currencyCode,
                    currencySymbol: trip.currencySymbol,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricColumn(
                  label: 'MEMBERS',
                  value: '${trip.memberCount}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: context.tripDetailsColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1.5,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: valueColor ?? context.tripDetailsColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParticipantsStrip extends StatelessWidget {
  const _ParticipantsStrip({required this.participants});

  final List<TripParticipant> participants;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: participants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final TripParticipant participant = participants[index];
          return _ParticipantTile(participant: participant, colorIndex: index);
        },
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant, required this.colorIndex});

  final TripParticipant participant;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final Color avatarBackground = _avatarBackground(
      context,
      participant,
      colorIndex,
    );
    final Color avatarTextColor = participant.isCurrentUser
        ? context.sharedColors.white
        : context.tripDetailsColors.textPrimary;

    return Container(
      constraints: BoxConstraints(
        minWidth: participant.isCurrentUser ? 78 : 88,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: participant.isCurrentUser
            ? context.sharedColors.cardBackground
            : context.tripDetailsColors.participantFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.tripDetailsColors.borderSoft.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: avatarBackground,
              shape: BoxShape.circle,
            ),
            child: Text(
              participant.dashboardLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                color: avatarTextColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _participantTileLabel(participant),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(
                color: context.tripDetailsColors.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.35,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              color: context.tripDetailsColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Icon(
          Icons.filter_list_rounded,
          size: 14,
          color: context.tripDetailsColors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          actionLabel,
          style: GoogleFonts.jetBrainsMono(
            color: context.tripDetailsColors.orange,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.45,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.trip, required this.expense});

  final TripSummary trip;
  final TripExpense expense;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>('trip_expense_${expense.referenceCode}'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.sharedColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.tripDetailsColors.borderSoft),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.sharedColors.shadowSubtle,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: context.sharedColors.transparent,
        child: InkWell(
          onTap: () => _openExpenseDetails(
            context,
            tripId: trip.id,
            expenseReferenceCode: expense.referenceCode,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: context.tripDetailsColors.orange,
                  width: 4,
                ),
              ),
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Widget metadata = Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    Text(
                      'PAID BY ${expense.paidBy.name.toUpperCase()}',
                      style: GoogleFonts.jetBrainsMono(
                        color: context.tripDetailsColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        letterSpacing: 0.9,
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.tripDetailsColors.borderSoft,
                        shape: BoxShape.circle,
                      ),
                    ),
                    _SplitBadge(splitType: expense.splitType),
                  ],
                );

                final Widget reference = _ExpenseReferenceTag(
                  referenceCode: expense.referenceCode,
                );

                final Widget amount = Text(
                  _formatTripCurrency(
                    expense.amount,
                    currencyCode: trip.currencyCode,
                    currencySymbol: trip.currencySymbol,
                  ),
                  textAlign: TextAlign.right,
                  style: GoogleFonts.jetBrainsMono(
                    color: context.tripDetailsColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                );

                if (constraints.maxWidth < 340) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              expense.title,
                              style: GoogleFonts.inter(
                                color: context.tripDetailsColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          amount,
                        ],
                      ),
                      const SizedBox(height: 10),
                      metadata,
                      const SizedBox(height: 10),
                      Align(alignment: Alignment.centerRight, child: reference),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            expense.title,
                            style: GoogleFonts.inter(
                              color: context.tripDetailsColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          metadata,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        amount,
                        const SizedBox(height: 10),
                        reference,
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitBadge extends StatelessWidget {
  const _SplitBadge({required this.splitType});

  final ExpenseSplitType splitType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.tripDetailsColors.splitFill,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _splitTypeLabel(splitType),
        style: GoogleFonts.jetBrainsMono(
          color: context.tripDetailsColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ExpenseReferenceTag extends StatelessWidget {
  const _ExpenseReferenceTag({required this.referenceCode});

  final String referenceCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.receipt_long_outlined,
          size: 13,
          color: context.tripDetailsColors.textMuted,
        ),
        const SizedBox(width: 4),
        Text(
          referenceCode,
          style: GoogleFonts.jetBrainsMono(
            color: context.tripDetailsColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _EmptyLedgerCard extends StatelessWidget {
  const _EmptyLedgerCard({required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.sharedColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tripDetailsColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No expenses yet',
            style: GoogleFonts.geist(
              color: context.tripDetailsColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add the first expense for ${trip.title} to start splitting costs.',
            style: GoogleFonts.inter(
              color: context.tripDetailsColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripTotalCard extends StatelessWidget {
  const _TripTotalCard({required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: context.tripDetailsColors.summaryFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.tripDetailsColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'TOTAL TRIP COST',
            style: GoogleFonts.jetBrainsMono(
              color: context.tripDetailsColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatTripCurrency(
              trip.total,
              currencyCode: trip.currencyCode,
              currencySymbol: trip.currencySymbol,
            ),
            style: GoogleFonts.geist(
              color: context.tripDetailsColors.orange,
              fontSize: 38,
              fontWeight: FontWeight.w700,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const ValueKey<String>('trip_details_settle_up_button'),
              onPressed: () => _openFinalSettleUp(context, trip.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.tripDetailsColors.orange,
                foregroundColor: context.sharedColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Settle Up',
                style: GoogleFonts.geist(
                  color: context.sharedColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final TripStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.detailBackgroundColor(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.detailLabel,
        style: GoogleFonts.jetBrainsMono(
          color: status.detailTextColor(context),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          height: 1.4,
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _AddExpenseButton extends StatelessWidget {
  const _AddExpenseButton({required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const ValueKey<String>('trip_details_add_expense_button'),
      heroTag: 'trip_details_add_expense_button',
      tooltip: 'Add expense',
      backgroundColor: context.tripDetailsColors.orange,
      foregroundColor: context.sharedColors.white,
      elevation: 8,
      splashColor: context.sharedColors.overlayWhite12,
      onPressed: () => _openCreateExpense(context, tripId),
      child: const Icon(Icons.add_rounded, size: 30),
    );
  }
}

class _DashedSeparator extends StatelessWidget {
  const _DashedSeparator();

  @override
  Widget build(BuildContext context) {
    const double dashWidth = 4;
    const double gapWidth = 3;
    const double thickness = 1;

    return SizedBox(
      height: thickness,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final int dashCount = (constraints.maxWidth / (dashWidth + gapWidth))
              .floor();

          return Row(
            children: List<Widget>.generate(dashCount, (int index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == dashCount - 1 ? 0 : gapWidth,
                ),
                child: SizedBox(
                  width: dashWidth,
                  height: thickness,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.tripDetailsColors.borderSoft,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

extension _TripDetailsStatusStyle on TripStatus {
  String get detailLabel {
    switch (this) {
      case TripStatus.inProgress:
        return 'ACTIVE';
      case TripStatus.upcoming:
        return 'UPCOMING';
      case TripStatus.settled:
        return 'SETTLED';
    }
  }

  Color detailBackgroundColor(BuildContext context) {
    switch (this) {
      case TripStatus.inProgress:
        return context.tripDetailsColors.orange;
      case TripStatus.upcoming:
        return context.tripDetailsColors.participantFill;
      case TripStatus.settled:
        return context.tripDetailsColors.green;
    }
  }

  Color detailTextColor(BuildContext context) {
    switch (this) {
      case TripStatus.inProgress:
        return context.tripDetailsColors.orangeText;
      case TripStatus.upcoming:
        return context.tripDetailsColors.textMuted;
      case TripStatus.settled:
        return context.tripDetailsColors.greenText;
    }
  }
}

String _participantTileLabel(TripParticipant participant) {
  if (participant.isCurrentUser) {
    return 'YOU';
  }

  final List<String> tokens = participant.name
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList(growable: false);

  if (tokens.isEmpty) {
    return participant.initials;
  }

  if (tokens.length == 1) {
    return tokens.first.toUpperCase();
  }

  return '${tokens.first.toUpperCase()}\n${tokens.last[0].toUpperCase()}.';
}

String _splitTypeLabel(ExpenseSplitType splitType) {
  switch (splitType) {
    case ExpenseSplitType.equally:
      return 'SPLIT EQUALLY';
    case ExpenseSplitType.custom:
      return 'SPLIT CUSTOM';
    case ExpenseSplitType.percent:
      return 'SPLIT BY %';
    case ExpenseSplitType.fixed:
      return 'SPLIT FIXED';
  }
}

Color _avatarBackground(
  BuildContext context,
  TripParticipant participant,
  int colorIndex,
) {
  if (participant.isCurrentUser) {
    return context.tripDetailsColors.orange;
  }

  final List<Color> palette = <Color>[
    context.sharedColors.participantAvatarBlue,
    context.sharedColors.participantAvatarSand,
    context.sharedColors.participantAvatarSlate,
    context.sharedColors.participantAvatarGreen,
  ];

  return palette[colorIndex % palette.length];
}
