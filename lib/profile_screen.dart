import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'app_routes.dart';
import 'trip_store.dart';
import 'tripsplit_bottom_nav.dart';

final Map<String, NumberFormat> _profileCurrencyFormatters =
    <String, NumberFormat>{};

String _formatProfileCurrency(
  double amount, {
  required String currencyCode,
  required String currencySymbol,
}) {
  final String formatterKey = '$currencyCode::$currencySymbol';
  final NumberFormat formatter = _profileCurrencyFormatters[formatterKey] ??=
      NumberFormat.currency(
        locale: 'en_US',
        name: currencyCode,
        symbol: currencySymbol,
        decimalDigits: 2,
      );

  return formatter.format(amount);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _expenseAddedNotifications = true;
  bool _settlementReminders = true;
  bool _tripInvitations = false;
  bool _biometricSecurity = true;

  void _showSoonMessage(String message) {
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _logOut() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      TripSplitRoutes.signIn,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<TripSummary> trips = TripStoreScope.of(context).trips;
    final _ProfileMetrics metrics = _ProfileMetrics.fromTrips(trips);
    final double horizontalPadding = MediaQuery.sizeOf(context).width < 360
        ? 14
        : 16;

    return Scaffold(
      key: const ValueKey<String>('profile_screen'),
      backgroundColor: _ProfilePalette.background,
      bottomNavigationBar: TripSplitBottomNav(
        activeTab: TripSplitBottomNavTab.profile,
        backgroundColor: _ProfilePalette.background,
        separatorColor: _ProfilePalette.cardBorder,
        activeFillColor: _ProfilePalette.orange,
        activeTextColor: _ProfilePalette.orangeText,
        inactiveTextColor: _ProfilePalette.textMuted,
        onCalculatorTap: () => Navigator.of(
          context,
        ).pushNamed(TripSplitRoutes.calculator),
        onTripsTap: () => Navigator.of(
          context,
        ).popUntil((Route<dynamic> route) => route.isFirst),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _ProfileHeader(
              onBack: () => Navigator.of(context).maybePop(),
              onEdit: () => _showSoonMessage('Profile editing tools are coming soon.'),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
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
                          _ProfileHeroCard(metrics: metrics),
                          const SizedBox(height: 24),
                          const _SectionTitle(text: 'PREFERENCES'),
                          const SizedBox(height: 10),
                          _SettingsCard(
                            children: <Widget>[
                              _DetailRow(
                                icon: Icons.paid_outlined,
                                label: 'Default currency',
                                value: metrics.currencyCode,
                                onTap: () => _showSoonMessage(
                                  'Default currency is based on your recent trip history.',
                                ),
                              ),
                              const _SettingsDivider(),
                              _DetailRow(
                                icon: Icons.dark_mode_outlined,
                                label: 'Theme',
                                value: 'System',
                                onTap: () => _showSoonMessage(
                                  'Theme settings follow your device for now.',
                                ),
                              ),
                              const _SettingsDivider(),
                              _DetailRow(
                                icon: Icons.call_split_rounded,
                                label: 'Split method',
                                value: metrics.splitMethodLabel,
                                onTap: () => _showSoonMessage(
                                  'Preferred split method reflects your current trips.',
                                ),
                              ),
                              const _SettingsDivider(),
                              _DetailRow(
                                icon: Icons.public_rounded,
                                label: 'Language',
                                value: 'English',
                                onTap: () => _showSoonMessage(
                                  'Multi-language settings are coming soon.',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle(text: 'NOTIFICATIONS'),
                          const SizedBox(height: 10),
                          _SettingsCard(
                            children: <Widget>[
                              _SwitchRow(
                                icon: Icons.receipt_long_outlined,
                                label: 'Expense added',
                                value: _expenseAddedNotifications,
                                onChanged: (bool value) {
                                  setState(() {
                                    _expenseAddedNotifications = value;
                                  });
                                },
                              ),
                              const _SettingsDivider(),
                              _SwitchRow(
                                icon: Icons.notifications_active_outlined,
                                label: 'Settlement reminder',
                                value: _settlementReminders,
                                onChanged: (bool value) {
                                  setState(() {
                                    _settlementReminders = value;
                                  });
                                },
                              ),
                              const _SettingsDivider(),
                              _SwitchRow(
                                icon: Icons.mail_outline_rounded,
                                label: 'Trip invitation',
                                value: _tripInvitations,
                                onChanged: (bool value) {
                                  setState(() {
                                    _tripInvitations = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const _SectionTitle(text: 'SECURITY'),
                          const SizedBox(height: 10),
                          _SettingsCard(
                            children: <Widget>[
                              _SwitchRow(
                                icon: Icons.fingerprint_rounded,
                                label: 'Face ID / Touch ID',
                                value: _biometricSecurity,
                                onChanged: (bool value) {
                                  setState(() {
                                    _biometricSecurity = value;
                                  });
                                },
                              ),
                              const _SettingsDivider(),
                              _DetailRow(
                                icon: Icons.ios_share_rounded,
                                label: 'Export my data',
                                onTap: () => _showSoonMessage(
                                  'Export tools are being prepared for a future update.',
                                ),
                                showChevron: true,
                              ),
                              const _SettingsDivider(),
                              _DetailRow(
                                icon: Icons.delete_outline_rounded,
                                label: 'Delete account',
                                onTap: () => _showSoonMessage(
                                  'Account deletion is not available in this prototype.',
                                ),
                                isDestructive: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              key: const ValueKey<String>('profile_logout_button'),
                              onPressed: _logOut,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _ProfilePalette.buttonFill,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'LOG OUT',
                                style: GoogleFonts.geist(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _ProfileVersionFooter(),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onBack, required this.onEdit});

  final VoidCallback onBack;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ProfilePalette.background,
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
                    splashRadius: 20,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: _ProfilePalette.orange,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/icons/plane.png',
                          width: 14,
                          height: 14,
                          color: _ProfilePalette.orange,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TRIPSPLIT',
                          style: GoogleFonts.jetBrainsMono(
                            color: _ProfilePalette.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'PASSENGER PROFILE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.geist(
                              color: _ProfilePalette.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onEdit,
                    splashRadius: 20,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: _ProfilePalette.orange,
                      size: 18,
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

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.metrics});

  final _ProfileMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _ProfilePalette.cardBorder),
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
          const _ProfileAvatar(),
          const SizedBox(height: 14),
          Text(
            'You',
            style: GoogleFonts.geist(
              color: _ProfilePalette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'you@example.com',
            style: GoogleFonts.jetBrainsMono(
              color: _ProfilePalette.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _ProfilePalette.tagFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _ProfilePalette.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: _ProfilePalette.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Member since 2026',
                  style: GoogleFonts.jetBrainsMono(
                    color: _ProfilePalette.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 64,
            child: _DashedSeparator(),
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _StatColumn(
                    label: 'Trips',
                    value: '${metrics.tripCount}',
                  ),
                ),
                const _VerticalDivider(),
                Expanded(
                  child: _StatColumn(
                    label: 'Expenses',
                    value: '${metrics.expenseCount}',
                  ),
                ),
                const _VerticalDivider(),
                Expanded(
                  child: _StatColumn(
                    label: 'Settled',
                    value: _formatProfileCurrency(
                      metrics.totalSettled,
                      currencyCode: metrics.currencyCode,
                      currencySymbol: metrics.currencySymbol,
                    ),
                    valueColor: _ProfilePalette.orange,
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

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 96,
          height: 96,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _ProfilePalette.orange, width: 2),
          ),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[Color(0xFFF6D4C0), Color(0xFFB77C5C)],
              ),
            ),
            child: Icon(Icons.person_rounded, size: 46, color: Colors.white),
          ),
        ),
        Positioned(
          bottom: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _ProfilePalette.orange,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white),
            ),
            child: Text(
              'VERIFIED',
              style: GoogleFonts.jetBrainsMono(
                color: _ProfilePalette.orangeText,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor = _ProfilePalette.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: _ProfilePalette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                color: valueColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: _ProfilePalette.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.45,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _ProfilePalette.cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
    this.showChevron = false,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isDestructive
        ? _ProfilePalette.red
        : _ProfilePalette.textPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: isDestructive
                    ? _ProfilePalette.red
                    : _ProfilePalette.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: labelColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    value!,
                    style: GoogleFonts.jetBrainsMono(
                      color: _ProfilePalette.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              if (showChevron)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: _ProfilePalette.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: _ProfilePalette.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: _ProfilePalette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeThumbColor: Colors.white,
              activeTrackColor: _ProfilePalette.orange,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: _ProfilePalette.switchTrack,
              trackOutlineColor: const WidgetStatePropertyAll<Color>(
                Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: _ProfilePalette.cardBorder,
    );
  }
}

class _ProfileVersionFooter extends StatelessWidget {
  const _ProfileVersionFooter();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.4,
      child: Column(
        children: <Widget>[
          Text(
            'TRIPSPLIT v1.0.0',
            style: GoogleFonts.jetBrainsMono(
              color: _ProfilePalette.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(width: 128, child: _DashedSeparator()),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: _ProfilePalette.cardBorder,
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
                      color: _ProfilePalette.cardBorder,
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

class _ProfileMetrics {
  const _ProfileMetrics({
    required this.tripCount,
    required this.expenseCount,
    required this.totalSettled,
    required this.currencyCode,
    required this.currencySymbol,
    required this.splitMethodLabel,
  });

  final int tripCount;
  final int expenseCount;
  final double totalSettled;
  final String currencyCode;
  final String currencySymbol;
  final String splitMethodLabel;

  factory _ProfileMetrics.fromTrips(List<TripSummary> trips) {
    final int tripCount = trips.length;
    final int expenseCount = trips.fold(
      0,
      (int total, TripSummary trip) => total + trip.expenses.length,
    );
    final double totalSettled = trips.fold(
      0,
      (double total, TripSummary trip) => total + trip.totalSettled,
    );
    final _PreferredCurrency preferredCurrency = _resolvePreferredCurrency(
      trips,
    );

    return _ProfileMetrics(
      tripCount: tripCount,
      expenseCount: expenseCount,
      totalSettled: totalSettled,
      currencyCode: preferredCurrency.code,
      currencySymbol: preferredCurrency.symbol,
      splitMethodLabel: _resolvePreferredSplitMethod(trips),
    );
  }
}

class _PreferredCurrency {
  const _PreferredCurrency({required this.code, required this.symbol});

  final String code;
  final String symbol;
}

_PreferredCurrency _resolvePreferredCurrency(List<TripSummary> trips) {
  if (trips.isEmpty) {
    return const _PreferredCurrency(code: 'EUR', symbol: '\u20AC');
  }

  final Map<String, int> usageCounts = <String, int>{};
  final Map<String, _PreferredCurrency> byKey = <String, _PreferredCurrency>{};

  for (final TripSummary trip in trips) {
    final String key = '${trip.currencyCode}::${trip.currencySymbol}';
    usageCounts[key] = (usageCounts[key] ?? 0) + 1;
    byKey[key] = _PreferredCurrency(
      code: trip.currencyCode,
      symbol: trip.currencySymbol,
    );
  }

  String selectedKey = byKey.keys.first;
  int bestCount = -1;

  for (final TripSummary trip in trips) {
    final String key = '${trip.currencyCode}::${trip.currencySymbol}';
    final int count = usageCounts[key] ?? 0;
    if (count > bestCount) {
      selectedKey = key;
      bestCount = count;
    }
  }

  return byKey[selectedKey]!;
}

String _resolvePreferredSplitMethod(List<TripSummary> trips) {
  if (trips.isEmpty) {
    return TripSplitType.equally.label;
  }

  final Map<TripSplitType, int> usageCounts = <TripSplitType, int>{};

  for (final TripSummary trip in trips) {
    usageCounts[trip.splitType] = (usageCounts[trip.splitType] ?? 0) + 1;
  }

  TripSplitType selected = trips.first.splitType;
  int bestCount = -1;

  for (final TripSummary trip in trips) {
    final int count = usageCounts[trip.splitType] ?? 0;
    if (count > bestCount) {
      selected = trip.splitType;
      bestCount = count;
    }
  }

  return selected.label;
}

class _ProfilePalette {
  static const Color background = Color(0xFFFDFAF6);
  static const Color buttonFill = Color(0xFF151B2B);
  static const Color tagFill = Color(0xFFF1EFE9);
  static const Color switchTrack = Color(0xFFE8E1DA);
  static const Color cardBorder = Color(0xFFDDC1B3);
  static const Color textPrimary = Color(0xFF151B2B);
  static const Color textMuted = Color(0xFF564338);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color orangeText = Color(0xFF532200);
  static const Color red = Color(0xFFBA1A1A);
}
