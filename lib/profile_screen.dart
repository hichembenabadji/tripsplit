import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'app_auth_controller.dart';
import 'app_colors.dart';
import 'app_routes.dart';
import 'app_theme_controller.dart';
import 'auth_service.dart';
import 'trip_store.dart';
import 'tripsplit_bottom_nav.dart';
import 'user_profile_widgets.dart';

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

  Future<void> _logOut() async {
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await AppAuthScope.read(context).signOut();

      if (!mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        TripSplitRoutes.signIn,
        (Route<dynamic> route) => false,
      );
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }

      _showSoonMessage(error.message);
    }
  }

  Future<void> _openEditProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final bool? profileUpdated =
        await Navigator.of(context).pushNamed(TripSplitRoutes.editProfile)
            as bool?;

    if (!mounted || profileUpdated != true) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
  }

  Future<void> _showThemeSelectorSheet() async {
    FocusManager.instance.primaryFocus?.unfocus();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(
        context,
      ).extension<AppColors>()!.shared.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      builder: (BuildContext context) {
        final AppThemeController sheetThemeController = AppThemeScope.of(
          context,
        );
        final AppColors sheetAppColors = Theme.of(
          context,
        ).extension<AppColors>()!;
        final ProfileColorTokens sheetColors = sheetAppColors.profile;
        final SharedColorTokens sheetShared = sheetAppColors.shared;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sheetColors.cardBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Theme',
                  style: GoogleFonts.geist(
                    color: sheetColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how TripSplit should look across the app.',
                  style: GoogleFonts.inter(
                    color: sheetColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: sheetShared.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sheetColors.cardBorder),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: sheetShared.shadowFaint,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    children: AppThemePreference.values
                        .map((AppThemePreference preference) {
                          final bool isSelected =
                              sheetThemeController.preference == preference;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                onTap: () async {
                                  await sheetThemeController.updatePreference(
                                    preference,
                                  );
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                leading: Icon(
                                  preference.icon,
                                  size: 20,
                                  color: sheetColors.textMuted,
                                ),
                                title: Text(
                                  preference.label,
                                  style: GoogleFonts.inter(
                                    color: sheetColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_rounded,
                                        size: 20,
                                        color: sheetColors.orange,
                                      )
                                    : null,
                              ),
                              if (preference != AppThemePreference.values.last)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: sheetColors.cardBorder,
                                ),
                            ],
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final ProfileColorTokens colors = appColors.profile;
    final AppThemeController themeController = AppThemeScope.of(context);
    final TripStore store = TripStoreScope.of(context);
    final List<TripSummary> trips = store.trips;
    final AppUserProfile currentUser = store.currentUser;
    final _ProfileMetrics metrics = _ProfileMetrics.fromTrips(trips);
    final double horizontalPadding = MediaQuery.sizeOf(context).width < 360
        ? 14
        : 16;

    return Scaffold(
      key: const ValueKey<String>('profile_screen'),
      backgroundColor: colors.background,
      bottomNavigationBar: TripSplitBottomNav(
        activeTab: TripSplitBottomNavTab.profile,
        backgroundColor: colors.background,
        separatorColor: colors.cardBorder,
        activeFillColor: colors.orange,
        activeTextColor: colors.orangeText,
        inactiveTextColor: colors.textMuted,
        onCalculatorTap: () =>
            Navigator.of(context).pushNamed(TripSplitRoutes.calculator),
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
              onEdit: _openEditProfile,
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
                          _ProfileHeroCard(
                            metrics: metrics,
                            currentUser: currentUser,
                          ),
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
                                value: themeController.preferenceLabel,
                                onTap: _showThemeSelectorSheet,
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
                              key: const ValueKey<String>(
                                'profile_logout_button',
                              ),
                              onPressed: _logOut,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.buttonFill,
                                foregroundColor: appColors.shared.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'LOG OUT',
                                style: GoogleFonts.geist(
                                  color: appColors.shared.white,
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
    final ProfileColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.profile;

    return Material(
      color: colors.background,
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
                    icon: Icon(Icons.arrow_back_rounded, color: colors.orange),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/icons/plane.png',
                          width: 14,
                          height: 14,
                          color: colors.orange,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'TRIPSPLIT',
                          style: GoogleFonts.jetBrainsMono(
                            color: colors.orange,
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
                              color: colors.textPrimary,
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
                    key: const ValueKey<String>('profile_edit_button'),
                    icon: Icon(
                      Icons.edit_outlined,
                      color: colors.orange,
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
  const _ProfileHeroCard({required this.metrics, required this.currentUser});

  final _ProfileMetrics metrics;
  final AppUserProfile currentUser;

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final ProfileColorTokens colors = appColors.profile;
    final SharedColorTokens shared = appColors.shared;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        color: shared.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shared.shadowSubtle,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _ProfileAvatar(currentUser: currentUser),
          const SizedBox(height: 14),
          Text(
            currentUser.displayName,
            style: GoogleFonts.geist(
              color: colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            currentUser.email,
            style: GoogleFonts.jetBrainsMono(
              color: colors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.tagFill,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: colors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'Member since ${currentUser.memberSince.year}',
                  style: GoogleFonts.jetBrainsMono(
                    color: colors.textPrimary,
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
          const SizedBox(width: 64, child: _DashedSeparator()),
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
                    valueColor: colors.orange,
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
  const _ProfileAvatar({required this.currentUser});

  final AppUserProfile currentUser;

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final ProfileColorTokens colors = appColors.profile;
    final SharedColorTokens shared = appColors.shared;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        TripSplitUserAvatar(
          imageBytes: currentUser.profileImageBytes,
          imageUrl: currentUser.profileImageUrl,
          size: 96,
          borderColor: colors.orange,
          borderWidth: 2,
          padding: 4,
          iconSize: 46,
        ),
        Positioned(
          bottom: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colors.orange,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: shared.white),
            ),
            child: Text(
              'VERIFIED',
              style: GoogleFonts.jetBrainsMono(
                color: colors.orangeText,
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
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final ProfileColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.profile;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: colors.textMuted,
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
                color: valueColor ?? colors.textPrimary,
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
    final ProfileColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.profile;

    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: colors.textMuted,
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
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final ProfileColorTokens colors = appColors.profile;
    final SharedColorTokens shared = appColors.shared;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: shared.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shared.shadowFaint,
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
    final ProfileColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.profile;
    final Color labelColor = isDestructive ? colors.red : colors.textPrimary;

    return Material(
      color: Theme.of(context).extension<AppColors>()!.shared.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: isDestructive ? colors.red : colors.textMuted,
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
                      color: colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              if (showChevron)
                Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: colors.textMuted,
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
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final ProfileColorTokens colors = appColors.profile;
    final SharedColorTokens shared = appColors.shared;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: colors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: colors.textPrimary,
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
              activeThumbColor: shared.white,
              activeTrackColor: colors.orange,
              inactiveThumbColor: shared.white,
              inactiveTrackColor: colors.switchTrack,
              trackOutlineColor: WidgetStatePropertyAll<Color>(
                shared.transparent,
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
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).extension<AppColors>()!.profile.cardBorder,
    );
  }
}

class _ProfileVersionFooter extends StatelessWidget {
  const _ProfileVersionFooter();

  @override
  Widget build(BuildContext context) {
    final ProfileColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.profile;

    return Opacity(
      opacity: 0.4,
      child: Column(
        children: <Widget>[
          Text(
            'TRIPSPLIT v1.0.0',
            style: GoogleFonts.jetBrainsMono(
              color: colors.textPrimary,
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
    final ProfileColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.profile;

    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: colors.cardBorder,
    );
  }
}

class _DashedSeparator extends StatelessWidget {
  const _DashedSeparator();

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(
      context,
    ).extension<AppColors>()!.profile.cardBorder;
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
