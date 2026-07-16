import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'app_routes.dart';
import 'create_trip.dart';
import 'trip_details.dart';
import 'trip_store.dart';
import 'tripsplit_bottom_nav.dart';

final Map<String, NumberFormat> _currencyFormatters = <String, NumberFormat>{};

String _formatCurrency(
  double amount, {
  required String currencyCode,
  required String currencySymbol,
}) {
  final String formatterKey = '$currencyCode::$currencySymbol';
  final NumberFormat formatter = _currencyFormatters[formatterKey] ??=
      NumberFormat.currency(
        locale: 'en_US',
        name: currencyCode,
        symbol: currencySymbol,
        decimalDigits: 2,
      );

  return formatter.format(amount);
}

String _formatSignedCurrency(
  double amount, {
  required String currencyCode,
  required String currencySymbol,
}) {
  final String sign = amount >= 0 ? '+' : '-';
  return '$sign ${_formatCurrency(amount.abs(), currencyCode: currencyCode, currencySymbol: currencySymbol)}';
}

void _openCreateTrip(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  assert(() {
    debugPrint('Dashboard add button pressed: navigating to CreateTripScreen');
    return true;
  }());

  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'create_trip'),
      builder: (BuildContext context) => const CreateTripScreen(),
    ),
  );
}

void _openTripDetails(BuildContext context, TripSummary trip) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'trip_details'),
      builder: (BuildContext context) => TripDetailsScreen(tripId: trip.id),
    ),
  );
}

void _openCalculator(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.calculator);
}

void _openProfile(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.profile);
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TripSummary> trips = TripStoreScope.of(context).trips;
    final Size screenSize = MediaQuery.sizeOf(context);
    final double horizontalPadding = screenSize.width < 360 ? 14 : 16;
    final double titleSize = screenSize.width < 360 ? 28 : 32;

    return Scaffold(
      backgroundColor: _DashboardPalette.background,
      bottomNavigationBar: TripSplitBottomNav(
        activeTab: TripSplitBottomNavTab.trips,
        backgroundColor: _DashboardPalette.background,
        separatorColor: _DashboardPalette.borderSoft,
        activeFillColor: _DashboardPalette.orange,
        activeTextColor: _DashboardPalette.orangeText,
        inactiveTextColor: _DashboardPalette.textSecondary,
        onCalculatorTap: () => _openCalculator(context),
        onProfileTap: () => _openProfile(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(right: 4, bottom: 18),
        child: _AddTripButton(),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const _DashboardHeader(),
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
                          _DashboardHero(titleSize: titleSize),
                          const SizedBox(height: 20),
                          _OverviewCard(
                            activeTrips: trips.length,
                            totalOutstanding: 312.45,
                            amountOwedToYou: 120.25,
                            amountYouOwe: 47.80,
                          ),
                          const SizedBox(height: 24),
                          for (final TripSummary trip in trips) ...<Widget>[
                            _TripCard(trip: trip),
                            const SizedBox(height: 18),
                          ],
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _DashboardPalette.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        'assets/icons/plane.png',
                        width: 18,
                        height: 18,
                        color: _DashboardPalette.orange,
                        colorBlendMode: BlendMode.srcIn,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'TRIPSPLIT',
                        style: GoogleFonts.geist(
                          color: _DashboardPalette.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const _ProfileAvatar(),
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _DashboardPalette.borderSoft),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFFF6D4C0), Color(0xFFB77C5C)],
          ),
        ),
        child: const Icon(Icons.person_rounded, size: 20, color: Colors.white),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({required this.titleSize});

  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'ACTIVE ITINERARIES',
          style: GoogleFonts.jetBrainsMono(
            color: _DashboardPalette.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.45,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'My Trips',
          style: GoogleFonts.geist(
            color: _DashboardPalette.textPrimary,
            fontSize: titleSize,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.activeTrips,
    required this.totalOutstanding,
    required this.amountOwedToYou,
    required this.amountYouOwe,
  });

  final int activeTrips;
  final double totalOutstanding;
  final double amountOwedToYou;
  final double amountYouOwe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DashboardPalette.border),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SectionLabel(text: 'GLOBAL OVERVIEW'),
                    const SizedBox(height: 4),
                    Text(
                      'Active Trips: $activeTrips',
                      style: GoogleFonts.inter(
                        color: _DashboardPalette.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const _SectionLabel(text: 'TOTAL OUTSTANDING'),
                  const SizedBox(height: 3),
                  Text(
                    _formatCurrency(
                      totalOutstanding,
                      currencyCode: 'EUR',
                      currencySymbol: '€',
                    ),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.jetBrainsMono(
                      color: _DashboardPalette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _DashedSeparator(),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: _BalanceTile(
                  label: 'YOU ARE OWED',
                  amount: amountOwedToYou,
                  amountColor: _DashboardPalette.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BalanceTile(
                  label: 'YOU OWE',
                  amount: -amountYouOwe,
                  amountColor: _DashboardPalette.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final String label;
  final double amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _DashboardPalette.borderSoft.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: _DashboardPalette.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatSignedCurrency(
                amount,
                currencyCode: 'EUR',
                currencySymbol: '€',
              ),
              style: GoogleFonts.jetBrainsMono(
                color: amountColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey<String>('dashboard_trip_${trip.title}'),
          onTap: () => _openTripDetails(context, trip),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _DashboardPalette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                                color: _DashboardPalette.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _StatusBadge(status: trip.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: _DashboardPalette.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              trip.dateRangeLabel,
                              style: GoogleFonts.inter(
                                color: _DashboardPalette.textMuted,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: trip.participants.map((
                          TripParticipant participant,
                        ) {
                          return _ParticipantChip(participant: participant);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const _DashedSeparator(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'TOTAL',
                        style: GoogleFonts.jetBrainsMono(
                          color: _DashboardPalette.textMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _formatCurrency(
                              trip.total,
                              currencyCode: trip.currencyCode,
                              currencySymbol: trip.currencySymbol,
                            ),
                            style: GoogleFonts.jetBrainsMono(
                              color: _DashboardPalette.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
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
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.label,
        style: GoogleFonts.jetBrainsMono(
          color: status.textColor,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }
}

class _ParticipantChip extends StatelessWidget {
  const _ParticipantChip({required this.participant});

  final TripParticipant participant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: participant.isCurrentUser
            ? _DashboardPalette.orange
            : _DashboardPalette.participantFill,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
      child: Text(
        participant.dashboardLabel,
        textAlign: TextAlign.center,
        style: GoogleFonts.jetBrainsMono(
          color: participant.isCurrentUser
              ? _DashboardPalette.orangeText
              : _DashboardPalette.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }
}

class _AddTripButton extends StatelessWidget {
  const _AddTripButton();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      key: const ValueKey<String>('dashboard_add_trip_button'),
      heroTag: 'dashboard_add_trip_button',
      tooltip: 'Create trip',
      backgroundColor: _DashboardPalette.orange,
      foregroundColor: Colors.white,
      elevation: 8,
      focusElevation: 8,
      hoverElevation: 8,
      highlightElevation: 10,
      splashColor: Colors.white.withValues(alpha: 0.12),
      onPressed: () => _openCreateTrip(context),
      child: const Icon(Icons.add_rounded, size: 30),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: _DashboardPalette.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.45,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _DashedSeparator extends StatelessWidget {
  const _DashedSeparator();

  @override
  Widget build(BuildContext context) {
    const Color color = _DashboardPalette.borderSoft;
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
                  child: DecoratedBox(decoration: BoxDecoration(color: color)),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

extension _TripStatusStyle on TripStatus {
  String get label {
    switch (this) {
      case TripStatus.inProgress:
        return 'IN PROGRESS';
      case TripStatus.upcoming:
        return 'UPCOMING';
      case TripStatus.settled:
        return 'SETTLED';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TripStatus.inProgress:
        return _DashboardPalette.orange;
      case TripStatus.upcoming:
        return _DashboardPalette.participantFill;
      case TripStatus.settled:
        return _DashboardPalette.green;
    }
  }

  Color get textColor {
    switch (this) {
      case TripStatus.inProgress:
        return _DashboardPalette.orangeText;
      case TripStatus.upcoming:
        return _DashboardPalette.textMuted;
      case TripStatus.settled:
        return _DashboardPalette.greenText;
    }
  }
}

class _DashboardPalette {
  static const Color background = Color(0xFFFDFAF6);
  static const Color participantFill = Color(0xFFE8E4DE);
  static const Color border = Color(0xFF564338);
  static const Color borderSoft = Color(0xFFA58C7F);
  static const Color textPrimary = Color(0xFF151B2B);
  static const Color textSecondary = Color(0xFF404758);
  static const Color textMuted = Color(0xFF564338);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color orangeText = Color(0xFF682D00);
  static const Color green = Color(0xFF22C268);
  static const Color greenText = Color(0xFF004922);
  static const Color red = Color(0xFFBA1A1A);
}
