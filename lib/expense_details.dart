import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'trip_store.dart';

final Map<String, NumberFormat> _expenseDetailsCurrencyFormatters =
    <String, NumberFormat>{};

String _formatExpenseDetailsCurrency(
  double amount, {
  required String currencyCode,
  required String currencySymbol,
}) {
  final String formatterKey = '$currencyCode::$currencySymbol';
  final NumberFormat formatter =
      _expenseDetailsCurrencyFormatters[formatterKey] ??= NumberFormat.currency(
        locale: 'en_US',
        name: currencyCode,
        symbol: currencySymbol,
        decimalDigits: 2,
      );

  return formatter.format(amount);
}

class ExpenseDetailsScreen extends StatelessWidget {
  const ExpenseDetailsScreen({
    super.key,
    required this.tripId,
    required this.expenseReferenceCode,
  });

  final String tripId;
  final String expenseReferenceCode;

  @override
  Widget build(BuildContext context) {
    final TripStore store = TripStoreScope.of(context);
    final TripSummary? trip = store.findTripById(tripId);
    final TripExpense? expense = store.findExpenseByReference(
      tripId: tripId,
      expenseReferenceCode: expenseReferenceCode,
    );
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double horizontalPadding = screenWidth < 360 ? 14 : 16;

    if (trip == null || expense == null) {
      return Scaffold(
        backgroundColor: _ExpenseDetailsPalette.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'This expense could not be found.',
                textAlign: TextAlign.center,
                style: GoogleFonts.geist(
                  color: _ExpenseDetailsPalette.textPrimary,
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

    final _ExpenseSplitDetails splitDetails = _buildExpenseSplitDetails(
      trip: trip,
      expense: expense,
    );

    return Scaffold(
      key: const ValueKey<String>('expense_details_screen'),
      backgroundColor: _ExpenseDetailsPalette.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _ExpenseDetailsHeader(
              onBack: () => Navigator.of(context).maybePop(),
              onDone: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16,
                  horizontalPadding,
                  24,
                ),
                children: <Widget>[
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _ExpenseHeroCard(
                            trip: trip,
                            expense: expense,
                            splitDetails: splitDetails,
                          ),
                          const SizedBox(height: 16),
                          _SplitMethodStrip(splitType: expense.splitType),
                          const SizedBox(height: 16),
                          const _ExpenseSectionTitle(title: 'SPLIT MANIFEST'),
                          const SizedBox(height: 12),
                          ...splitDetails.rows.map((_ExpenseSplitRowData row) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _SplitManifestCard(
                                trip: trip,
                                expense: expense,
                                row: row,
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
                          _ExpenseSummaryCard(
                            trip: trip,
                            splitDetails: splitDetails,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _ApplySplitButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Split details are balanced and ready.',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseDetailsHeader extends StatelessWidget {
  const _ExpenseDetailsHeader({required this.onBack, required this.onDone});

  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ExpenseDetailsPalette.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: onBack,
                    splashRadius: 22,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: _ExpenseDetailsPalette.orange,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Split Details',
                          style: GoogleFonts.geist(
                            color: _ExpenseDetailsPalette.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'CALCULATION LOGIC',
                          style: GoogleFonts.jetBrainsMono(
                            color: _ExpenseDetailsPalette.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onDone,
                    style: TextButton.styleFrom(
                      foregroundColor: _ExpenseDetailsPalette.saveText,
                      minimumSize: const Size(52, 36),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.geist(
                        color: _ExpenseDetailsPalette.saveText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.43,
                      ),
                    ),
                  ),
                ],
              ),
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

class _ExpenseHeroCard extends StatelessWidget {
  const _ExpenseHeroCard({
    required this.trip,
    required this.expense,
    required this.splitDetails,
  });

  final TripSummary trip;
  final TripExpense expense;
  final _ExpenseSplitDetails splitDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _ExpenseDetailsPalette.borderSoft),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 340;
          final Widget amountBlock = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'TOTAL',
                textAlign: compact ? TextAlign.left : TextAlign.right,
                style: GoogleFonts.jetBrainsMono(
                  color: _ExpenseDetailsPalette.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatExpenseDetailsCurrency(
                  expense.amount,
                  currencyCode: trip.currencyCode,
                  currencySymbol: trip.currencySymbol,
                ),
                textAlign: compact ? TextAlign.left : TextAlign.right,
                style: GoogleFonts.jetBrainsMono(
                  color: _ExpenseDetailsPalette.orange,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (compact) ...<Widget>[
                Text(
                  'TRANSACTION',
                  style: GoogleFonts.jetBrainsMono(
                    color: _ExpenseDetailsPalette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.title,
                  style: GoogleFonts.geist(
                    color: _ExpenseDetailsPalette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                amountBlock,
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'TRANSACTION',
                            style: GoogleFonts.jetBrainsMono(
                              color: _ExpenseDetailsPalette.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.45,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expense.title,
                            style: GoogleFonts.geist(
                              color: _ExpenseDetailsPalette.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    amountBlock,
                  ],
                ),
              const SizedBox(height: 14),
              const _SoftDivider(),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final bool stacked = constraints.maxWidth < 320;
                  final Widget payerColumn = _DetailMetaColumn(
                    label: 'PAID BY',
                    child: _PaidByBadge(
                      participant: splitDetails.payer,
                      colorIndex: splitDetails.colorIndexForParticipant(
                        splitDetails.payer,
                      ),
                    ),
                  );
                  final Widget participantsColumn = _DetailMetaColumn(
                    label: 'PARTICIPANTS',
                    crossAxisAlignment: CrossAxisAlignment.end,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: _ParticipantBadgeStack(
                        participants: splitDetails.involvedParticipants,
                        colorIndexForParticipant:
                            splitDetails.colorIndexForParticipant,
                      ),
                    ),
                  );

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        payerColumn,
                        const SizedBox(height: 14),
                        participantsColumn,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(child: payerColumn),
                      const SizedBox(width: 16),
                      Expanded(child: participantsColumn),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailMetaColumn extends StatelessWidget {
  const _DetailMetaColumn({
    required this.label,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final String label;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: <Widget>[
        Text(
          label,
          textAlign: crossAxisAlignment == CrossAxisAlignment.end
              ? TextAlign.right
              : TextAlign.left,
          style: GoogleFonts.jetBrainsMono(
            color: _ExpenseDetailsPalette.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.45,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _PaidByBadge extends StatelessWidget {
  const _PaidByBadge({required this.participant, required this.colorIndex});

  final TripParticipant participant;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final Color avatarColor = _participantAvatarColor(participant, colorIndex);
    final Color textColor = participant.isCurrentUser
        ? Colors.white
        : _ExpenseDetailsPalette.textPrimary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: avatarColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: _ExpenseDetailsPalette.borderSoft.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            participant.dashboardLabel,
            style: GoogleFonts.jetBrainsMono(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            _participantDisplayName(participant),
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _ExpenseDetailsPalette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _ParticipantBadgeStack extends StatelessWidget {
  const _ParticipantBadgeStack({
    required this.participants,
    required this.colorIndexForParticipant,
  });

  final List<TripParticipant> participants;
  final int Function(TripParticipant participant) colorIndexForParticipant;

  @override
  Widget build(BuildContext context) {
    final int count = participants.length;
    final double diameter = 24;
    final double overlap = 6;
    final double width = count == 0 ? diameter : diameter + (count - 1) * 18;

    return SizedBox(
      width: width,
      height: diameter,
      child: Stack(
        children: List<Widget>.generate(count, (int index) {
          final TripParticipant participant = participants[index];
          return Positioned(
            left: index * 18,
            child: _TinyParticipantBadge(
              participant: participant,
              colorIndex: colorIndexForParticipant(participant),
              diameter: diameter,
              borderWidth: overlap > 0 ? 1.5 : 0,
            ),
          );
        }),
      ),
    );
  }
}

class _TinyParticipantBadge extends StatelessWidget {
  const _TinyParticipantBadge({
    required this.participant,
    required this.colorIndex,
    required this.diameter,
    required this.borderWidth,
  });

  final TripParticipant participant;
  final int colorIndex;
  final double diameter;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _participantAvatarColor(participant, colorIndex),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: borderWidth),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        participant.dashboardLabel,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: participant.isCurrentUser
              ? Colors.white
              : _ExpenseDetailsPalette.textPrimary,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
    );
  }
}

class _SplitMethodStrip extends StatelessWidget {
  const _SplitMethodStrip({required this.splitType});

  final ExpenseSplitType splitType;

  @override
  Widget build(BuildContext context) {
    const List<_SplitMethodLabel> labels = <_SplitMethodLabel>[
      _SplitMethodLabel(ExpenseSplitType.equally, 'Equally'),
      _SplitMethodLabel(ExpenseSplitType.fixed, 'Fixed Amount'),
      _SplitMethodLabel(ExpenseSplitType.percent, 'Percentage'),
      _SplitMethodLabel(ExpenseSplitType.custom, 'Custom'),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _ExpenseDetailsPalette.segmentFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _ExpenseDetailsPalette.borderSoft.withValues(alpha: 0.3),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: labels
              .map((_SplitMethodLabel entry) {
                final bool selected = entry.splitType == splitType;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? _ExpenseDetailsPalette.orange
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: selected
                          ? const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      entry.label,
                      style: GoogleFonts.jetBrainsMono(
                        color: selected
                            ? Colors.white
                            : _ExpenseDetailsPalette.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _SplitMethodLabel {
  const _SplitMethodLabel(this.splitType, this.label);

  final ExpenseSplitType splitType;
  final String label;
}

class _ExpenseSectionTitle extends StatelessWidget {
  const _ExpenseSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.jetBrainsMono(
        color: _ExpenseDetailsPalette.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.45,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _SplitManifestCard extends StatelessWidget {
  const _SplitManifestCard({
    required this.trip,
    required this.expense,
    required this.row,
  });

  final TripSummary trip;
  final TripExpense expense;
  final _ExpenseSplitRowData row;

  @override
  Widget build(BuildContext context) {
    final bool highlightCurrentUser = row.participant.isCurrentUser;
    final Color borderColor = highlightCurrentUser
        ? _ExpenseDetailsPalette.orange.withValues(alpha: 0.45)
        : _ExpenseDetailsPalette.borderSoft.withValues(alpha: 0.35);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 320;
          final Widget amountGroup = Column(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'PORTION',
                textAlign: compact ? TextAlign.left : TextAlign.right,
                style: GoogleFonts.jetBrainsMono(
                  color: _ExpenseDetailsPalette.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _PortionPill(
                    child: Text(
                      _formatExpenseDetailsCurrency(
                        row.amount,
                        currencyCode: trip.currencyCode,
                        currencySymbol: trip.currencySymbol,
                      ),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.jetBrainsMono(
                        color: _ExpenseDetailsPalette.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _PortionPill(
                    child: Text(
                      _formatSharePercentage(row.percentage),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        color: _ExpenseDetailsPalette.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          final Widget participantMeta = Row(
            children: <Widget>[
              _ManifestAvatar(
                participant: row.participant,
                colorIndex: row.colorIndex,
                showPaidMarker: row.isPayer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _participantDisplayName(row.participant),
                        style: GoogleFonts.inter(
                          color: row.participant.isCurrentUser
                              ? _ExpenseDetailsPalette.orangeText
                              : _ExpenseDetailsPalette.textPrimary,
                          fontSize: 16,
                          fontWeight: row.participant.isCurrentUser
                              ? FontWeight.w600
                              : FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _manifestStatusLabel(
                          participant: row.participant,
                          payer: expense.paidBy,
                        ),
                        style: GoogleFonts.jetBrainsMono(
                          color: row.isPayer
                              ? _ExpenseDetailsPalette.orange
                              : _ExpenseDetailsPalette.textMuted,
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                participantMeta,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: amountGroup),
              ],
            );
          }

          return Row(
            children: <Widget>[
              Expanded(child: participantMeta),
              const SizedBox(width: 12),
              amountGroup,
            ],
          );
        },
      ),
    );
  }
}

class _ManifestAvatar extends StatelessWidget {
  const _ManifestAvatar({
    required this.participant,
    required this.colorIndex,
    required this.showPaidMarker,
  });

  final TripParticipant participant;
  final int colorIndex;
  final bool showPaidMarker;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _participantAvatarColor(participant, colorIndex),
              shape: BoxShape.circle,
              border: Border.all(
                color: _ExpenseDetailsPalette.borderSoft.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              participant.dashboardLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: participant.isCurrentUser
                    ? Colors.white
                    : _ExpenseDetailsPalette.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          if (showPaidMarker)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _ExpenseDetailsPalette.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PortionPill extends StatelessWidget {
  const _PortionPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 52),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _ExpenseDetailsPalette.portionFill,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({required this.trip, required this.splitDetails});

  final TripSummary trip;
  final _ExpenseSplitDetails splitDetails;

  @override
  Widget build(BuildContext context) {
    final bool balanced = splitDetails.remaining.abs() < 0.01;
    final Color remainingColor = balanced
        ? _ExpenseDetailsPalette.green
        : _ExpenseDetailsPalette.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _ExpenseDetailsPalette.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SummaryMetricRow(
            label: 'TOTAL DECLARED',
            value: _formatExpenseDetailsCurrency(
              splitDetails.totalDeclared,
              currencyCode: trip.currencyCode,
              currencySymbol: trip.currencySymbol,
            ),
          ),
          const SizedBox(height: 8),
          _SummaryMetricRow(
            label: 'TOTAL ASSIGNED',
            value: _formatExpenseDetailsCurrency(
              splitDetails.totalAssigned,
              currencyCode: trip.currencyCode,
              currencySymbol: trip.currencySymbol,
            ),
          ),
          const SizedBox(height: 8),
          _SummaryMetricRow(
            label: 'REMAINING',
            value: _formatExpenseDetailsCurrency(
              splitDetails.remaining,
              currencyCode: trip.currencyCode,
              currencySymbol: trip.currencySymbol,
            ),
            valueColor: remainingColor,
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: _ExpenseDetailsPalette.borderSoft.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  balanced
                      ? Icons.verified_rounded
                      : Icons.error_outline_rounded,
                  size: 18,
                  color: balanced
                      ? _ExpenseDetailsPalette.green
                      : _ExpenseDetailsPalette.red,
                ),
                const SizedBox(width: 8),
                Text(
                  balanced ? 'BALANCED SPLIT' : 'UNBALANCED SPLIT',
                  style: GoogleFonts.jetBrainsMono(
                    color: balanced
                        ? _ExpenseDetailsPalette.green
                        : _ExpenseDetailsPalette.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetricRow extends StatelessWidget {
  const _SummaryMetricRow({
    required this.label,
    required this.value,
    this.valueColor = _ExpenseDetailsPalette.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: _ExpenseDetailsPalette.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: _SummaryDashedLine()),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryDashedLine extends StatelessWidget {
  const _SummaryDashedLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double dashWidth = 4;
          const double gapWidth = 3;
          final int dashCount = (constraints.maxWidth / (dashWidth + gapWidth))
              .floor();

          return Row(
            children: List<Widget>.generate(dashCount, (int index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == dashCount - 1 ? 0 : gapWidth,
                ),
                child: const SizedBox(
                  width: dashWidth,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _ExpenseDetailsPalette.borderSoft,
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

class _ApplySplitButton extends StatelessWidget {
  const _ApplySplitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        key: const ValueKey<String>('expense_details_apply_split_button'),
        onPressed: onPressed,
        icon: const Icon(
          Icons.fact_check_outlined,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          'Apply Split',
          style: GoogleFonts.geist(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _ExpenseDetailsPalette.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[Color(0x66A58C7F), Color(0x00A58C7F)],
        ),
      ),
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
                child: const SizedBox(
                  width: dashWidth,
                  height: thickness,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _ExpenseDetailsPalette.borderSoft,
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

class _ExpenseSplitDetails {
  const _ExpenseSplitDetails({
    required this.payer,
    required this.involvedParticipants,
    required this.rows,
    required this.totalDeclared,
    required this.totalAssigned,
    required this.remaining,
    required this.colorIndexByParticipantKey,
  });

  final TripParticipant payer;
  final List<TripParticipant> involvedParticipants;
  final List<_ExpenseSplitRowData> rows;
  final double totalDeclared;
  final double totalAssigned;
  final double remaining;
  final Map<String, int> colorIndexByParticipantKey;

  int colorIndexForParticipant(TripParticipant participant) {
    return colorIndexByParticipantKey[_participantKey(participant)] ?? 0;
  }
}

class _ExpenseSplitRowData {
  const _ExpenseSplitRowData({
    required this.participant,
    required this.amount,
    required this.percentage,
    required this.isPayer,
    required this.colorIndex,
  });

  final TripParticipant participant;
  final double amount;
  final double percentage;
  final bool isPayer;
  final int colorIndex;
}

_ExpenseSplitDetails _buildExpenseSplitDetails({
  required TripSummary trip,
  required TripExpense expense,
}) {
  final TripParticipant payer = _resolveTripParticipant(trip, expense.paidBy);
  final List<TripParticipant> selectedBeneficiaries =
      _canonicalizeParticipantsForTrip(
        trip,
        expense.beneficiaries.isEmpty
            ? <TripParticipant>[payer]
            : expense.beneficiaries,
      );
  final List<TripParticipant> beneficiaries = selectedBeneficiaries.isEmpty
      ? <TripParticipant>[payer]
      : selectedBeneficiaries;
  final Map<String, int> colorIndexByParticipantKey = <String, int>{};

  for (int index = 0; index < trip.participants.length; index += 1) {
    colorIndexByParticipantKey[_participantKey(trip.participants[index])] =
        index;
  }

  if (!colorIndexByParticipantKey.containsKey(_participantKey(payer))) {
    colorIndexByParticipantKey[_participantKey(payer)] =
        colorIndexByParticipantKey.length;
  }

  final List<TripParticipant> involvedParticipants = <TripParticipant>[payer];

  for (final TripParticipant participant in trip.participants) {
    if (_containsParticipant(beneficiaries, participant) &&
        !_containsParticipant(involvedParticipants, participant)) {
      involvedParticipants.add(participant);
    }
  }

  for (final TripParticipant participant in beneficiaries) {
    if (!_containsParticipant(involvedParticipants, participant)) {
      involvedParticipants.add(participant);
      colorIndexByParticipantKey[_participantKey(participant)] =
          colorIndexByParticipantKey.length;
    }
  }

  final int totalCents = (expense.amount * 100).round();
  final int beneficiaryCount = beneficiaries.length;
  final List<int> splitCents = List<int>.filled(beneficiaryCount, 0);

  if (beneficiaryCount > 0) {
    final int baseShare = totalCents ~/ beneficiaryCount;
    final int remainder = totalCents % beneficiaryCount;

    for (int index = 0; index < beneficiaryCount; index += 1) {
      splitCents[index] = baseShare + (index < remainder ? 1 : 0);
    }
  }

  final Map<String, int> amountByParticipantKey = <String, int>{};
  for (int index = 0; index < beneficiaries.length; index += 1) {
    amountByParticipantKey[_participantKey(beneficiaries[index])] =
        splitCents[index];
  }

  final List<_ExpenseSplitRowData> rows = involvedParticipants
      .map((TripParticipant participant) {
        final String key = _participantKey(participant);
        final int amountCents = amountByParticipantKey[key] ?? 0;
        final double percentage = totalCents == 0
            ? 0
            : (amountCents / totalCents) * 100;

        return _ExpenseSplitRowData(
          participant: participant,
          amount: amountCents / 100,
          percentage: percentage,
          isPayer: _sameParticipant(participant, payer),
          colorIndex: colorIndexByParticipantKey[key] ?? 0,
        );
      })
      .toList(growable: false);

  final int totalAssignedCents = amountByParticipantKey.values.fold<int>(
    0,
    (int sum, int amountCents) => sum + amountCents,
  );
  final int remainingCents = totalCents - totalAssignedCents;

  return _ExpenseSplitDetails(
    payer: payer,
    involvedParticipants: involvedParticipants,
    rows: rows,
    totalDeclared: totalCents / 100,
    totalAssigned: totalAssignedCents / 100,
    remaining: remainingCents / 100,
    colorIndexByParticipantKey: colorIndexByParticipantKey,
  );
}

List<TripParticipant> _canonicalizeParticipantsForTrip(
  TripSummary trip,
  List<TripParticipant> participants,
) {
  final List<TripParticipant> uniqueParticipants = <TripParticipant>[];

  for (final TripParticipant participant in participants) {
    final TripParticipant canonical = _resolveTripParticipant(
      trip,
      participant,
    );
    if (!_containsParticipant(uniqueParticipants, canonical)) {
      uniqueParticipants.add(canonical);
    }
  }

  return uniqueParticipants;
}

TripParticipant _resolveTripParticipant(
  TripSummary trip,
  TripParticipant participant,
) {
  for (final TripParticipant candidate in trip.participants) {
    if (_sameParticipant(candidate, participant)) {
      return candidate;
    }
  }

  return participant;
}

bool _containsParticipant(
  List<TripParticipant> participants,
  TripParticipant participant,
) {
  for (final TripParticipant candidate in participants) {
    if (_sameParticipant(candidate, participant)) {
      return true;
    }
  }

  return false;
}

bool _sameParticipant(TripParticipant left, TripParticipant right) {
  return _participantKey(left) == _participantKey(right);
}

String _participantKey(TripParticipant participant) {
  return '${participant.name}|${participant.initials}|${participant.isCurrentUser}';
}

String _participantDisplayName(TripParticipant participant) {
  if (participant.isCurrentUser) {
    return 'You';
  }

  final List<String> parts = participant.name
      .split(RegExp(r'\s+'))
      .where((String value) => value.isNotEmpty)
      .toList(growable: false);

  if (parts.isEmpty) {
    return participant.initials;
  }

  if (parts.length == 1) {
    return parts.first;
  }

  return '${parts.first} ${parts.last[0].toUpperCase()}.';
}

String _manifestStatusLabel({
  required TripParticipant participant,
  required TripParticipant payer,
}) {
  if (_sameParticipant(participant, payer)) {
    return 'PAID FULL';
  }

  final String owesName = payer.isCurrentUser
      ? 'YOU'
      : payer.name.split(RegExp(r'\s+')).first.toUpperCase();
  return 'OWES $owesName';
}

String _formatSharePercentage(double percentage) {
  final double rounded = double.parse(percentage.toStringAsFixed(1));
  if (rounded == rounded.roundToDouble()) {
    return '${rounded.round()}%';
  }

  return '${rounded.toStringAsFixed(1)}%';
}

Color _participantAvatarColor(TripParticipant participant, int colorIndex) {
  if (participant.isCurrentUser) {
    return _ExpenseDetailsPalette.currentUserAvatar;
  }

  const List<Color> palette = <Color>[
    Color(0xFFDCE2F8),
    Color(0xFFFFDBC9),
    Color(0xFF6DFE9C),
    Color(0xFFE2E3DF),
    Color(0xFFE3D9F4),
  ];

  return palette[colorIndex % palette.length];
}

class _ExpenseDetailsPalette {
  static const Color background = Color(0xFFF8F6F1);
  static const Color segmentFill = Color(0xFFEEEEEC);
  static const Color portionFill = Color(0xFFF0F1ED);
  static const Color border = Color(0xFFD5C3B9);
  static const Color borderSoft = Color(0xFFA58C7F);
  static const Color textPrimary = Color(0xFF151B2B);
  static const Color textMuted = Color(0xFF564338);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color orangeText = Color(0xFF682D00);
  static const Color saveText = Color(0xFF9A4600);
  static const Color green = Color(0xFF006D36);
  static const Color red = Color(0xFFBA1A1A);
  static const Color currentUserAvatar = Color(0xFFFFC9AE);
}
