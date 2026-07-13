import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/split_method.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/users_repository.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _returnController = TextEditingController();
  final TextEditingController _memberQueryController = TextEditingController();

  String _selectedCurrency = 'EUR';
  SplitMethod _selectedSplitMethod = SplitMethod.equally;
  final List<String> _selectedMemberIds = <String>[
    'user-alex',
    'user-jordan',
    'user-casey',
  ];

  static const _screenBackground = Color(0xFFFDFCFB);
  static const _headerDivider = Color(0xFFDCE2F8);
  static const _cardBorder = Color(0xFFDCE2F8);
  static const _cardShadow = Color(0x0C000000);
  static const _brandOrange = Color(0xFFFF8A3D);
  static const _titleColor = Color(0xFF151B2B);
  static const _bodyColor = Color(0xFF564338);
  static const _mutedHint = Color(0x7F564338);
  static const _inputFill = Color(0xFFF8F6F2);
  static const _splitBackground = Color(0xFFF8F6F2);
  static const _darkButton = Color(0xFF151B2B);
  static const _memberDivider = Color(0x4CA58C7F);

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _departureController.dispose();
    _returnController.dispose();
    _memberQueryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider);
    final selectedMembers = users
        .where((user) => _selectedMemberIds.contains(user.id))
        .toList();

    return ColoredBox(
      color: _screenBackground,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _CreateTripHeader(onBack: context.pop, onSave: () {}),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 24.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 448.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'NEW ITINERARY',
                          style: GoogleFonts.jetBrainsMono(
                            color: _bodyColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            letterSpacing: 1.1.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Create Trip',
                          style: GoogleFonts.geist(
                            color: _titleColor,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: _cardBorder),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: _cardShadow,
                                blurRadius: 30.r,
                                offset: Offset(0, 10.h),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _LabeledField(
                                  label: 'TRIP NAME',
                                  child: _TripTextField(
                                    controller: _tripNameController,
                                    hintText: 'e.g. Paris Weekend',
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                _LabeledField(
                                  label: 'DESTINATION OR ACTIVITY',
                                  child: _TripTextField(
                                    controller: _destinationController,
                                    hintText: 'e.g. Paris, Restaurant...',
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: _LabeledField(
                                        label: 'DEPARTURE',
                                        child: _TripTextField(
                                          controller: _departureController,
                                          hintText: 'mm/dd/yyyy',
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: _LabeledField(
                                        label: 'RETURN',
                                        child: _TripTextField(
                                          controller: _returnController,
                                          hintText: 'mm/dd/yyyy',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.h),
                                const _DashedSectionDivider(),
                                SizedBox(height: 24.h),
                                _LabeledField(
                                  label: 'CURRENCY',
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          for (final currency in <String>[
                                            'EUR',
                                            'USD',
                                            'GBP',
                                            'DZD',
                                          ]) ...<Widget>[
                                            _CurrencyChip(
                                              label: currency,
                                              selected:
                                                  currency == _selectedCurrency,
                                              onTap: () {
                                                setState(() {
                                                  _selectedCurrency = currency;
                                                });
                                              },
                                            ),
                                            if (currency != 'DZD')
                                              SizedBox(width: 8.w),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      Container(
                                        width: 8.w,
                                        height: 18.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFA58C7F),
                                          borderRadius: BorderRadius.circular(
                                            99.r,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                const _DashedSectionDivider(),
                                SizedBox(height: 24.h),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        'PASSENGER LIST',
                                        style: GoogleFonts.jetBrainsMono(
                                          color: _bodyColor,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                          height: 1.45,
                                          letterSpacing: 1.1.sp,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${selectedMembers.length + 1} MEMBERS',
                                      style: GoogleFonts.jetBrainsMono(
                                        color: _bodyColor,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        height: 1.45,
                                        letterSpacing: 1.1.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: <Widget>[
                                    const _PassengerChip.you(),
                                    for (final member in selectedMembers)
                                      _PassengerChip.user(
                                        user: member,
                                        onRemove: () =>
                                            _removeMember(member.id),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: _inputFill,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: TextField(
                                          controller: _memberQueryController,
                                          style: GoogleFonts.inter(
                                            color: _titleColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 12.h,
                                                ),
                                            hintText: 'Name or email',
                                            hintStyle: GoogleFonts.inter(
                                              color: _mutedHint,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      TextButton(
                                        onPressed: () => _addMember(users),
                                        style: TextButton.styleFrom(
                                          backgroundColor: _darkButton,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16.w,
                                            vertical: 7.h,
                                          ),
                                          minimumSize: Size(66.w, 48.h),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8.r,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'ADD\nMEMBER',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.jetBrainsMono(
                                            color: _screenBackground,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400,
                                            height: 1.5,
                                            letterSpacing: -0.25.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                const _DashedSectionDivider(),
                                SizedBox(height: 24.h),
                                Text(
                                  'SPLIT TYPE',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: _bodyColor,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.45,
                                    letterSpacing: 1.1.sp,
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: _splitBackground,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: _SplitOption(
                                          label: 'Equally',
                                          selected:
                                              _selectedSplitMethod ==
                                              SplitMethod.equally,
                                          onTap: () {
                                            setState(() {
                                              _selectedSplitMethod =
                                                  SplitMethod.equally;
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: _SplitOption(
                                          label: 'Custom',
                                          selected:
                                              _selectedSplitMethod ==
                                              SplitMethod.fixed,
                                          onTap: () {
                                            setState(() {
                                              _selectedSplitMethod =
                                                  SplitMethod.fixed;
                                            });
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: _SplitOption(
                                          label: 'Percent',
                                          selected:
                                              _selectedSplitMethod ==
                                              SplitMethod.percentage,
                                          onTap: () {
                                            setState(() {
                                              _selectedSplitMethod =
                                                  SplitMethod.percentage;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: context.pop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandOrange,
                              minimumSize: Size.fromHeight(64.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: Text(
                              'CREATE TRIP',
                              style: GoogleFonts.geist(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                letterSpacing: -0.5.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Center(
                          child: Text(
                            'You can add expenses after creating the trip.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: _bodyColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeMember(String userId) {
    setState(() {
      _selectedMemberIds.remove(userId);
    });
  }

  void _addMember(List<User> users) {
    final query = _memberQueryController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return;
    }

    for (final user in users) {
      final matches =
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);

      if (matches && !_selectedMemberIds.contains(user.id)) {
        setState(() {
          _selectedMemberIds.add(user.id);
          _memberQueryController.clear();
        });
        return;
      }
    }
  }
}

class _CreateTripHeader extends StatelessWidget {
  const _CreateTripHeader({required this.onBack, required this.onSave});

  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        color: _CreateTripScreenState._screenBackground,
        border: Border(
          bottom: BorderSide(color: _CreateTripScreenState._headerDivider),
        ),
      ),
      child: Row(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(999.r),
            onTap: onBack,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
              child: Image.asset(
                'assets/icons/arrow_left.png',
                width: 20.w,
                height: 20.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'TRIPSPLIT',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.geist(
                  color: _CreateTripScreenState._brandOrange,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -1.2.sp,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onSave,
            style: TextButton.styleFrom(
              foregroundColor: _CreateTripScreenState._brandOrange,
              padding: EdgeInsets.zero,
              minimumSize: Size(38.w, 28.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'SAVE',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                color: _CreateTripScreenState._brandOrange,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                height: 1.45,
                letterSpacing: 1.1.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            color: _CreateTripScreenState._bodyColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            height: 1.45,
            letterSpacing: 1.1.sp,
          ),
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

class _TripTextField extends StatelessWidget {
  const _TripTextField({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _CreateTripScreenState._inputFill,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          color: _CreateTripScreenState._titleColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            color: _CreateTripScreenState._mutedHint,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  const _CurrencyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: selected
                  ? _CreateTripScreenState._brandOrange
                  : _CreateTripScreenState._cardBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                color: selected
                    ? _CreateTripScreenState._brandOrange
                    : _CreateTripScreenState._bodyColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitOption extends StatelessWidget {
  const _SplitOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: const Color(0x0C000000),
                    blurRadius: 2.r,
                    offset: Offset(0, 1.h),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              color: selected
                  ? _CreateTripScreenState._titleColor
                  : _CreateTripScreenState._bodyColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
        ),
      ),
    );
  }
}

class _PassengerChip extends StatelessWidget {
  const _PassengerChip._({
    required this.label,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeTextColor,
    this.onRemove,
  });

  const _PassengerChip.you()
    : this._(
        label: 'You',
        badgeLabel: 'Y',
        badgeColor: const Color(0xFFFF8A3D),
        badgeTextColor: const Color(0xFFFDFCFB),
      );

  factory _PassengerChip.user({
    required User user,
    required VoidCallback onRemove,
  }) {
    final spec = _memberBadgeSpecForUser(user);

    return _PassengerChip._(
      label: user.name,
      badgeLabel: user.initials,
      badgeColor: spec.background,
      badgeTextColor: spec.foreground,
      onRemove: onRemove,
    );
  }

  final String label;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: _CreateTripScreenState._cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              badgeLabel,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                color: badgeTextColor,
                fontSize: badgeLabel.length > 1 ? 8.5.sp : 10.sp,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: GoogleFonts.inter(
              color: _CreateTripScreenState._titleColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
          if (onRemove != null) ...<Widget>[
            SizedBox(width: 8.w),
            InkWell(
              borderRadius: BorderRadius.circular(99.r),
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14.sp,
                color: _CreateTripScreenState._bodyColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static _PassengerChipColors _memberBadgeSpecForUser(User user) {
    switch (user.id) {
      case 'user-alex':
        return const _PassengerChipColors(
          background: Color(0xFFD8DEFF),
          foreground: Color(0xFF5E6DAA),
        );
      case 'user-jordan':
        return const _PassengerChipColors(
          background: Color(0xFF75E28A),
          foreground: Color(0xFF0F5B1E),
        );
      case 'user-casey':
        return const _PassengerChipColors(
          background: Color(0xFFDCE5FF),
          foreground: Color(0xFF5C6EAC),
        );
      default:
        return const _PassengerChipColors(
          background: Color(0xFFE8E4DE),
          foreground: Color(0xFF564338),
        );
    }
  }
}

class _PassengerChipColors {
  const _PassengerChipColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}

class _DashedSectionDivider extends StatelessWidget {
  const _DashedSectionDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 6.w).floor();

        return Opacity(
          opacity: 0.3,
          child: Row(
            children: List<Widget>.generate(dashCount, (index) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Container(
                    height: 2.h,
                    color: _CreateTripScreenState._memberDivider,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
