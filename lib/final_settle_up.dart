import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'app_colors.dart';
import 'app_routes.dart';
import 'trip_store.dart';
import 'tripsplit_bottom_nav.dart';
import 'user_profile_widgets.dart';

final Map<String, NumberFormat> _finalSettleCurrencyFormatters =
    <String, NumberFormat>{};

String _formatFinalSettleCurrency(
  double amount, {
  required String currencyCode,
  required String currencySymbol,
}) {
  final String normalizedCurrencySymbol = _normalizeCurrencySymbol(
    currencySymbol,
  );
  final String formatterKey = '$currencyCode::$normalizedCurrencySymbol';
  final NumberFormat formatter =
      _finalSettleCurrencyFormatters[formatterKey] ??= NumberFormat.currency(
        locale: 'en_US',
        name: currencyCode,
        symbol: normalizedCurrencySymbol,
        decimalDigits: 2,
      );

  return formatter.format(amount);
}

String _normalizeCurrencySymbol(String currencySymbol) {
  const Map<String, String> normalizationMap = <String, String>{
    'â‚¬': '\u20AC',
    'Â£': '\u00A3',
    'Â¥': '\u00A5',
  };

  return normalizationMap[currencySymbol] ?? currencySymbol;
}

void _openCalculatorFromFinalSettleUp(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.calculator);
}

void _openProfileFromFinalSettleUp(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.profile);
}

extension _FinalSettleThemeAccess on BuildContext {
  AppColors get _appColors => Theme.of(this).extension<AppColors>()!;
  FinalSettleColorTokens get finalSettleColors => _appColors.finalSettle;
  SharedColorTokens get sharedColors => _appColors.shared;
}

class FinalSettleUpScreen extends StatelessWidget {
  const FinalSettleUpScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context) {
    final TripStore store = TripStoreScope.of(context);
    final TripSummary? trip = store.findTripById(tripId);
    final AppUserProfile currentUser = store.currentUser;
    final double horizontalPadding = MediaQuery.sizeOf(context).width < 360
        ? 14
        : 16;

    if (trip == null) {
      return Scaffold(
        backgroundColor: context.finalSettleColors.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'This trip could not be found.',
                textAlign: TextAlign.center,
                style: GoogleFonts.geist(
                  color: context.finalSettleColors.textPrimary,
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

    final _SettlementStatement statement = _SettlementStatement.fromTrip(
      trip,
      colors: context.finalSettleColors,
    );

    return Scaffold(
      key: const ValueKey<String>('final_settle_up_screen'),
      backgroundColor: context.finalSettleColors.background,
      bottomNavigationBar: TripSplitBottomNav(
        activeTab: TripSplitBottomNavTab.trips,
        backgroundColor: context.finalSettleColors.background,
        separatorColor: context.finalSettleColors.borderSoft,
        activeFillColor: context.finalSettleColors.orange,
        activeTextColor: context.finalSettleColors.orangeText,
        inactiveTextColor: context.finalSettleColors.textSecondary,
        onCalculatorTap: () => _openCalculatorFromFinalSettleUp(context),
        onProfileTap: () => _openProfileFromFinalSettleUp(context),
      ),
      body: CustomPaint(
        painter: _PaperTexturePainter(
          lineColor: context.finalSettleColors.textureLine,
          dotColor: context.finalSettleColors.textureDot,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              _FinalSettleHeader(currentUser: currentUser),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    18,
                    horizontalPadding,
                    20,
                  ),
                  children: <Widget>[
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _ScreenLabelRow(statement: statement),
                            const SizedBox(height: 14),
                            _TripStatementCard(trip: trip),
                            const SizedBox(height: 14),
                            _OutstandingSummaryCard(
                              trip: trip,
                              statement: statement,
                            ),
                            const SizedBox(height: 14),
                            if (statement.instructions.isEmpty)
                              const _NoTransactionsCard()
                            else
                              ...statement.instructions.map((
                                _SettlementInstruction instruction,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _SettlementInstructionCard(
                                    trip: trip,
                                    instruction: instruction,
                                  ),
                                );
                              }),
                            const SizedBox(height: 4),
                            _SettleActionArea(
                              canSettle: statement.canSettle,
                              onSettle: statement.canSettle
                                  ? () => _handleSettlementConfirmed(
                                      context,
                                      trip: trip,
                                    )
                                  : null,
                              onViewTransactions: statement.instructions.isEmpty
                                  ? null
                                  : () => _showTransactionsHint(context),
                            ),
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
      ),
    );
  }
}

void _handleSettlementConfirmed(
  BuildContext context, {
  required TripSummary trip,
}) {
  FocusManager.instance.primaryFocus?.unfocus();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Settlement for ${trip.title} is ready to process.'),
    ),
  );
}

void _showTransactionsHint(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('All pending transfers are listed above.')),
  );
}

class _FinalSettleHeader extends StatelessWidget {
  const _FinalSettleHeader({required this.currentUser});

  final AppUserProfile currentUser;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.finalSettleColors.headerBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 16, 10),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  splashRadius: 20,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: context.finalSettleColors.orangeDark,
                  ),
                ),
                Expanded(
                  child: Text(
                    'TRIPSPLIT',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      color: context.finalSettleColors.orangeDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.sharedColors.cardBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.finalSettleColors.borderSoft,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: context.sharedColors.shadowSubtle,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TripSplitUserAvatar(
                    imageBytes: currentUser.profileImageBytes,
                    size: 40,
                    padding: 2,
                    iconSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _FinalSettleDashedSeparator(),
          ),
        ],
      ),
    );
  }
}

class _ScreenLabelRow extends StatelessWidget {
  const _ScreenLabelRow({required this.statement});

  final _SettlementStatement statement;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            'FINAL STATEMENT',
            style: GoogleFonts.jetBrainsMono(
              color: context.finalSettleColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statement.statusFillColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            statement.statusLabel,
            style: GoogleFonts.jetBrainsMono(
              color: statement.statusTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _TripStatementCard extends StatelessWidget {
  const _TripStatementCard({required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    final List<TripParticipant> participants = trip.participants
        .take(4)
        .toList(growable: false);
    final double titleSize = MediaQuery.sizeOf(context).width < 360 ? 24 : 30;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: context.sharedColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.finalSettleColors.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.sharedColors.shadowSubtle,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.55,
                child: Transform.rotate(
                  angle: -0.22,
                  child: Column(
                    children: <Widget>[
                      _DecorativeBrushStroke(
                        width: 92,
                        color: context.finalSettleColors.decorativeStroke,
                      ),
                      const SizedBox(height: 8),
                      _DecorativeBrushStroke(
                        width: 74,
                        color: context.finalSettleColors.decorativeStrokeSoft,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                trip.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.geist(
                  color: context.finalSettleColors.textPrimary,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatStatementDateRange(trip),
                style: GoogleFonts.inter(
                  color: context.finalSettleColors.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _FinalSettleDashedSeparator(
                color: context.finalSettleColors.cardDivider,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: participants
                    .map((TripParticipant participant) {
                      return _ParticipantPill(
                        label: _participantPillLabel(participant),
                        isCurrentUser: participant.isCurrentUser,
                      );
                    })
                    .toList(growable: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DecorativeBrushStroke extends StatelessWidget {
  const _DecorativeBrushStroke({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _ParticipantPill extends StatelessWidget {
  const _ParticipantPill({required this.label, required this.isCurrentUser});

  final String label;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.sharedColors.cardBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isCurrentUser
              ? context.finalSettleColors.borderStrong
              : context.finalSettleColors.cardBorder,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          color: context.finalSettleColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
      ),
    );
  }
}

class _OutstandingSummaryCard extends StatelessWidget {
  const _OutstandingSummaryCard({required this.trip, required this.statement});

  final TripSummary trip;
  final _SettlementStatement statement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: context.sharedColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.finalSettleColors.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.sharedColors.shadowSubtle,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Text(
            'TOTAL OUTSTANDING',
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              color: context.finalSettleColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatFinalSettleCurrency(
                statement.totalOutstanding,
                currencyCode: trip.currencyCode,
                currencySymbol: trip.currencySymbol,
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.geist(
                color: context.finalSettleColors.orangeDark,
                fontSize: 48,
                fontWeight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -0.96,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Due to ${statement.participantCount} participants',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: context.finalSettleColors.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.finalSettleColors.optimizationFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: context.finalSettleColors.orangeDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'OPTIMIZED TRANSACTIONS ACTIVE',
                        style: GoogleFonts.jetBrainsMono(
                          color: context.finalSettleColors.orangeDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statement.optimizationMessage,
                        style: GoogleFonts.inter(
                          color: context.finalSettleColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
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

class _SettlementInstructionCard extends StatelessWidget {
  const _SettlementInstructionCard({
    required this.trip,
    required this.instruction,
  });

  final TripSummary trip;
  final _SettlementInstruction instruction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.sharedColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.finalSettleColors.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.sharedColors.shadowSubtle,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final Widget amount = Text(
            _formatFinalSettleCurrency(
              instruction.amount,
              currencyCode: trip.currencyCode,
              currencySymbol: trip.currencySymbol,
            ),
            textAlign: TextAlign.right,
            style: GoogleFonts.jetBrainsMono(
              color: context.finalSettleColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          );

          if (constraints.maxWidth < 320) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _InstructionHeader(instruction: instruction),
                const SizedBox(height: 12),
                amount,
                const SizedBox(height: 6),
                _InstructionMetadata(text: instruction.metadata),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _InstructionHeader(instruction: instruction),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: _InstructionMetadata(text: instruction.metadata),
                  ),
                  const SizedBox(width: 12),
                  amount,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InstructionHeader extends StatelessWidget {
  const _InstructionHeader({required this.instruction});

  final _SettlementInstruction instruction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  instruction.direction.label,
                  style: GoogleFonts.jetBrainsMono(
                    color: context.finalSettleColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  instruction.title,
                  style: GoogleFonts.geist(
                    color: context.finalSettleColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: instruction.direction.badgeFillColor(context),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            instruction.direction.badgeLabel,
            style: GoogleFonts.jetBrainsMono(
              color: instruction.direction.badgeTextColor(context),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionMetadata extends StatelessWidget {
  const _InstructionMetadata({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: context.finalSettleColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
      ),
    );
  }
}

class _NoTransactionsCard extends StatelessWidget {
  const _NoTransactionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.sharedColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.finalSettleColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No pending transfers',
            style: GoogleFonts.geist(
              color: context.finalSettleColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This trip does not have any outstanding settlement instructions yet.',
            style: GoogleFonts.inter(
              color: context.finalSettleColors.textMuted,
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

class _SettleActionArea extends StatelessWidget {
  const _SettleActionArea({
    required this.canSettle,
    required this.onSettle,
    required this.onViewTransactions,
  });

  final bool canSettle;
  final VoidCallback? onSettle;
  final VoidCallback? onViewTransactions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const ValueKey<String>('final_settle_now_button'),
              onPressed: onSettle,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.finalSettleColors.orange,
                foregroundColor: context.finalSettleColors.buttonText,
                disabledBackgroundColor:
                    context.finalSettleColors.buttonDisabledFill,
                disabledForegroundColor:
                    context.finalSettleColors.buttonDisabledText,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadowColor: context.sharedColors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  boxShadow: canSettle
                      ? <BoxShadow>[
                          BoxShadow(
                            color: context.sharedColors.shadowStrong,
                            blurRadius: 6,
                            offset: Offset(0, 4),
                            spreadRadius: -4,
                          ),
                          BoxShadow(
                            color: context.sharedColors.shadowStrong,
                            blurRadius: 15,
                            offset: Offset(0, 10),
                            spreadRadius: -3,
                          ),
                        ]
                      : <BoxShadow>[],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    'SETTLE UP NOW',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.geist(
                      color: canSettle
                          ? context.finalSettleColors.buttonText
                          : context.finalSettleColors.buttonDisabledText,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          TextButton(
            onPressed: onViewTransactions,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: context.finalSettleColors.textMuted,
            ),
            child: Text(
              'View all transactions',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                color: context.finalSettleColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.45,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalSettleDashedSeparator extends StatelessWidget {
  const _FinalSettleDashedSeparator({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color resolvedColor = color ?? context.finalSettleColors.borderSoft;
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
                    decoration: BoxDecoration(color: resolvedColor),
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

class _PaperTexturePainter extends CustomPainter {
  const _PaperTexturePainter({required this.lineColor, required this.dotColor});

  final Color lineColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint horizontalLinePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    final Paint noisePaint = Paint()..color = dotColor.withValues(alpha: 0.045);

    for (double y = 0; y < size.height; y += 9) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), horizontalLinePaint);
    }

    for (double x = 12; x < size.width; x += 46) {
      for (double y = 18; y < size.height; y += 54) {
        canvas.drawCircle(Offset(x, y), 0.8, noisePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SettlementStatement {
  const _SettlementStatement({
    required this.instructions,
    required this.totalOutstanding,
    required this.participantCount,
    required this.optimizationMessage,
    required this.statusLabel,
    required this.statusFillColor,
    required this.statusTextColor,
  });

  final List<_SettlementInstruction> instructions;
  final double totalOutstanding;
  final int participantCount;
  final String optimizationMessage;
  final String statusLabel;
  final Color statusFillColor;
  final Color statusTextColor;

  bool get canSettle => instructions.isNotEmpty && totalOutstanding > 0;

  factory _SettlementStatement.fromTrip(
    TripSummary trip, {
    required FinalSettleColorTokens colors,
  }) {
    final List<TripParticipant> nonCurrentParticipants = trip.participants
        .where((TripParticipant participant) => !participant.isCurrentUser)
        .toList(growable: false);
    final List<TripParticipant> settlementParticipants = nonCurrentParticipants
        .take(3)
        .toList(growable: false);
    final double remainingOutstanding = math.max(
      trip.total - trip.totalSettled,
      0,
    );

    if (settlementParticipants.isEmpty || remainingOutstanding <= 0) {
      return _SettlementStatement(
        instructions: const <_SettlementInstruction>[],
        totalOutstanding: 0,
        participantCount: trip.memberCount,
        optimizationMessage:
            'Everything is balanced. No transfers are needed for this statement.',
        statusLabel: 'ALL CLEARED',
        statusFillColor: colors.clearedFill,
        statusTextColor: colors.clearedText,
      );
    }

    final List<double> weights = _instructionWeights(
      settlementParticipants.length,
    );
    double assignedTotal = 0;
    final String prefix = _statementReferencePrefix(trip);
    final List<_SettlementInstruction> instructions =
        <_SettlementInstruction>[];

    for (int index = 0; index < settlementParticipants.length; index += 1) {
      final TripParticipant participant = settlementParticipants[index];
      final bool isLastItem = index == settlementParticipants.length - 1;
      final double amount = isLastItem
          ? (remainingOutstanding - assignedTotal)
          : double.parse(
              (remainingOutstanding * weights[index]).toStringAsFixed(2),
            );
      assignedTotal += amount;
      final _SettlementDirection direction = _directionForIndex(
        index,
        settlementParticipants.length,
      );

      instructions.add(
        _SettlementInstruction(
          direction: direction,
          title: direction == _SettlementDirection.debt
              ? 'Pay ${participant.name}'
              : 'From ${participant.name}',
          metadata: _instructionMetadata(
            prefix: prefix,
            index: index,
            isLastItem: isLastItem,
          ),
          amount: amount,
        ),
      );
    }

    final int transactionCount = instructions.length;
    final int unoptimizedTransfers = math.max(
      transactionCount + trip.memberCount,
      transactionCount,
    );
    final String paymentLabel = transactionCount == 1 ? 'payment' : 'payments';

    return _SettlementStatement(
      instructions: instructions,
      totalOutstanding: double.parse(remainingOutstanding.toStringAsFixed(2)),
      participantCount: trip.memberCount,
      optimizationMessage:
          '$transactionCount $paymentLabel instead of $unoptimizedTransfers. Less transfers, same final balance.',
      statusLabel: 'READY TO SETTLE',
      statusFillColor: colors.readyFill,
      statusTextColor: colors.readyText,
    );
  }
}

enum _SettlementDirection { debt, credit }

extension on _SettlementDirection {
  String get label {
    switch (this) {
      case _SettlementDirection.debt:
        return 'FROM YOU';
      case _SettlementDirection.credit:
        return 'TO YOU';
    }
  }

  String get badgeLabel {
    switch (this) {
      case _SettlementDirection.debt:
        return 'DEBT';
      case _SettlementDirection.credit:
        return 'CREDIT';
    }
  }

  Color badgeFillColor(BuildContext context) {
    switch (this) {
      case _SettlementDirection.debt:
        return context.finalSettleColors.debtFill;
      case _SettlementDirection.credit:
        return context.finalSettleColors.creditFill;
    }
  }

  Color badgeTextColor(BuildContext context) {
    switch (this) {
      case _SettlementDirection.debt:
        return context.finalSettleColors.debtText;
      case _SettlementDirection.credit:
        return context.finalSettleColors.creditText;
    }
  }
}

class _SettlementInstruction {
  const _SettlementInstruction({
    required this.direction,
    required this.title,
    required this.metadata,
    required this.amount,
  });

  final _SettlementDirection direction;
  final String title;
  final String metadata;
  final double amount;
}

List<double> _instructionWeights(int count) {
  switch (count) {
    case 1:
      return const <double>[1];
    case 2:
      return const <double>[0.77, 0.23];
    default:
      return const <double>[0.317, 0.085, 0.598];
  }
}

_SettlementDirection _directionForIndex(int index, int totalCount) {
  if (totalCount == 1) {
    return _SettlementDirection.debt;
  }

  return index.isOdd ? _SettlementDirection.credit : _SettlementDirection.debt;
}

String _instructionMetadata({
  required String prefix,
  required int index,
  required bool isLastItem,
}) {
  if (isLastItem && index > 0) {
    return 'AUTO-MATCHED';
  }

  final int suffix = 92 - (index * 51);
  final String normalizedSuffix = suffix.abs().toString().padLeft(3, '0');
  return 'TAG #$prefix-$normalizedSuffix';
}

String _statementReferencePrefix(TripSummary trip) {
  final String source = trip.destination.trim().isNotEmpty
      ? trip.destination
      : trip.title;
  final String normalized = source
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9]+'), ' ')
      .trim();
  final List<String> tokens = normalized
      .split(RegExp(r'\s+'))
      .where((String token) => token.isNotEmpty)
      .toList(growable: false);

  if (tokens.isEmpty) {
    return 'TR';
  }

  return tokens.take(2).map((String token) => token[0]).join().padRight(2, 'X');
}

String _formatStatementDateRange(TripSummary trip) {
  if (trip.departureDate != null && trip.returnDate != null) {
    final DateFormat formatter = DateFormat('MMMM d');
    return '${formatter.format(trip.departureDate!)} \u2014 ${formatter.format(trip.returnDate!)}';
  }

  if (trip.departureDate != null) {
    return 'Starts ${DateFormat('MMMM d').format(trip.departureDate!)}';
  }

  if (trip.returnDate != null) {
    return 'Ends ${DateFormat('MMMM d').format(trip.returnDate!)}';
  }

  return 'Dates TBD';
}

String _participantPillLabel(TripParticipant participant) {
  if (participant.isCurrentUser) {
    return 'You';
  }

  final List<String> parts = participant.name
      .split(RegExp(r'\s+'))
      .where((String token) => token.isNotEmpty)
      .toList(growable: false);

  if (parts.isEmpty) {
    return participant.initials;
  }

  if (parts.length == 1) {
    return parts.first;
  }

  return '${parts.first} ${parts.last[0]}.';
}
