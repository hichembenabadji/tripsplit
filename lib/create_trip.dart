import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'app_routes.dart';
import 'trip_store.dart';
import 'tripsplit_bottom_nav.dart';

void _openCalculatorFromCreateTrip(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.calculator);
}

void _openProfileFromCreateTrip(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.profile);
}

class CreateTripScreen extends StatefulWidget {
  const CreateTripScreen({super.key});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  static final CurrencyService _currencyService = CurrencyService();
  static final Currency _defaultCurrency =
      _currencyService.findByCode('EUR') ?? _currencyService.getAll().first;

  final TextEditingController _tripNameController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();

  final List<_TripMember> _members = <_TripMember>[
    const _TripMember(
      name: 'You',
      initials: 'Y',
      avatarColor: _CreateTripPalette.orange,
      avatarTextColor: Colors.white,
      isCurrentUser: true,
    ),
    const _TripMember(
      name: 'Alex Rivera',
      initials: 'AR',
      avatarColor: _CreateTripPalette.avatarBlue,
      avatarTextColor: _CreateTripPalette.avatarBlueText,
    ),
    const _TripMember(
      name: 'Jordan Smith',
      initials: 'JS',
      avatarColor: _CreateTripPalette.avatarGreen,
      avatarTextColor: _CreateTripPalette.avatarGreenText,
    ),
    const _TripMember(
      name: 'Casey Wong',
      initials: 'CW',
      avatarColor: _CreateTripPalette.avatarSoft,
      avatarTextColor: _CreateTripPalette.avatarBlueText,
    ),
  ];

  DateTime? _departureDate;
  DateTime? _returnDate;
  String _selectedCurrencyCode = _defaultCurrency.code;
  TripSplitType _selectedSplitType = TripSplitType.equally;

  Currency get _resolvedSelectedCurrency {
    return _currencyService.findByCode(_selectedCurrencyCode) ??
        _defaultCurrency;
  }

  @override
  void dispose() {
    _tripNameController.dispose();
    _destinationController.dispose();
    _memberController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDeparture}) async {
    final DateTime now = kTripSplitToday;
    final DateTime initialDate = isDeparture
        ? (_departureDate ?? now)
        : (_returnDate ?? _departureDate ?? now);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _CreateTripPalette.orange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _CreateTripPalette.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      if (isDeparture) {
        _departureDate = pickedDate;
        if (_returnDate != null && _returnDate!.isBefore(pickedDate)) {
          _returnDate = pickedDate;
        }
      } else {
        _returnDate = pickedDate;
      }
    });
  }

  void _addMember() {
    final String rawValue = _memberController.text.trim();
    if (rawValue.isEmpty) {
      return;
    }

    final _AvatarStyle avatarStyle =
        _memberAvatarStyles[_members.length % _memberAvatarStyles.length];

    setState(() {
      _members.add(
        _TripMember(
          name: rawValue,
          initials: _buildInitials(rawValue),
          avatarColor: avatarStyle.backgroundColor,
          avatarTextColor: avatarStyle.textColor,
        ),
      );
      _memberController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  void _removeMember(_TripMember member) {
    if (member.isCurrentUser) {
      return;
    }

    setState(() {
      _members.remove(member);
    });
  }

  void _saveDraft() {
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trip draft saved locally.')));
  }

  void _showCurrencyPickerSheet() {
    FocusManager.instance.primaryFocus?.unfocus();

    showCurrencyPicker(
      context: context,
      showSearchField: true,
      showFlag: true,
      showCurrencyName: true,
      showCurrencyCode: true,
      showDragHandle: true,
      onSelect: (Currency currency) {
        setState(() {
          _selectedCurrencyCode = currency.code;
        });
      },
      theme: CurrencyPickerThemeData(
        backgroundColor: _CreateTripPalette.background,
        bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.82,
        flagSize: 24,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        titleTextStyle: GoogleFonts.geist(
          color: _CreateTripPalette.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          color: _CreateTripPalette.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        currencySignTextStyle: GoogleFonts.jetBrainsMono(
          color: _CreateTripPalette.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        inputDecoration: InputDecoration(
          hintText: 'Search currencies',
          hintStyle: GoogleFonts.inter(
            color: _CreateTripPalette.textPlaceholder,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _CreateTripPalette.textSecondary,
          ),
          filled: true,
          fillColor: _CreateTripPalette.fieldFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _CreateTripPalette.cardBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _CreateTripPalette.cardBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _CreateTripPalette.orange),
          ),
        ),
      ),
    );
  }

  void _createTrip() {
    FocusManager.instance.primaryFocus?.unfocus();
    final Currency selectedCurrency = _resolvedSelectedCurrency;

    if (_tripNameController.text.trim().isEmpty ||
        _destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a trip name and destination first.')),
      );
      return;
    }

    TripStoreScope.read(context).addTrip(
      title: _tripNameController.text,
      destination: _destinationController.text,
      currencyCode: selectedCurrency.code,
      currencyName: selectedCurrency.name,
      currencySymbol: selectedCurrency.symbol,
      currencyFlag: _currencyFlagEmoji(selectedCurrency),
      participants: _members
          .map((_TripMember member) => member.toTripParticipant())
          .toList(growable: false),
      splitType: _selectedSplitType,
      departureDate: _departureDate,
      returnDate: _returnDate,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final double horizontalPadding = screenSize.width < 360 ? 14 : 16;

    return Scaffold(
      key: const ValueKey<String>('create_trip_screen'),
      backgroundColor: _CreateTripPalette.background,
      bottomNavigationBar: TripSplitBottomNav(
        activeTab: TripSplitBottomNavTab.trips,
        backgroundColor: _CreateTripPalette.background,
        separatorColor: _CreateTripPalette.separator,
        activeFillColor: _CreateTripPalette.orange,
        activeTextColor: _CreateTripPalette.orangeText,
        inactiveTextColor: _CreateTripPalette.textMuted,
        onCalculatorTap: () => _openCalculatorFromCreateTrip(context),
        onProfileTap: () => _openProfileFromCreateTrip(context),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _CreateTripHeader(onSave: _saveDraft),
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
                          const _CreateTripHero(),
                          const SizedBox(height: 20),
                          _CreateTripCard(
                            tripNameController: _tripNameController,
                            destinationController: _destinationController,
                            memberController: _memberController,
                            departureDate: _departureDate,
                            returnDate: _returnDate,
                            members: _members,
                            selectedCurrency: _resolvedSelectedCurrency,
                            selectedSplitType: _selectedSplitType,
                            onDepartureTap: () => _pickDate(isDeparture: true),
                            onReturnTap: () => _pickDate(isDeparture: false),
                            onCurrencyTap: _showCurrencyPickerSheet,
                            onSplitTypeSelected: (TripSplitType splitType) {
                              setState(() {
                                _selectedSplitType = splitType;
                              });
                            },
                            onAddMember: _addMember,
                            onRemoveMember: _removeMember,
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
                16,
                horizontalPadding,
                12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _CreateTripPrimaryButton(onPressed: _createTrip),
                      const SizedBox(height: 12),
                      Text(
                        'You can add expenses after creating the trip.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: _CreateTripPalette.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
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

class _CreateTripHeader extends StatelessWidget {
  const _CreateTripHeader({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _CreateTripPalette.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/icons/arrow_left.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'TRIPSPLIT',
                        style: GoogleFonts.geist(
                          color: _CreateTripPalette.orange,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -1.1,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onSave,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(40, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: _CreateTripPalette.orange,
                    ),
                    child: Text(
                      'SAVE',
                      style: GoogleFonts.jetBrainsMono(
                        color: _CreateTripPalette.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        letterSpacing: 1.1,
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

class _CreateTripHero extends StatelessWidget {
  const _CreateTripHero();

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'NEW ITINERARY',
          style: GoogleFonts.jetBrainsMono(
            color: _CreateTripPalette.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.45,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Create Trip',
          style: GoogleFonts.geist(
            color: _CreateTripPalette.textPrimary,
            fontSize: compact ? 30 : 32,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _CreateTripCard extends StatelessWidget {
  const _CreateTripCard({
    required this.tripNameController,
    required this.destinationController,
    required this.memberController,
    required this.departureDate,
    required this.returnDate,
    required this.members,
    required this.selectedCurrency,
    required this.selectedSplitType,
    required this.onDepartureTap,
    required this.onReturnTap,
    required this.onCurrencyTap,
    required this.onSplitTypeSelected,
    required this.onAddMember,
    required this.onRemoveMember,
  });

  final TextEditingController tripNameController;
  final TextEditingController destinationController;
  final TextEditingController memberController;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final List<_TripMember> members;
  final Currency selectedCurrency;
  final TripSplitType selectedSplitType;
  final VoidCallback onDepartureTap;
  final VoidCallback onReturnTap;
  final VoidCallback onCurrencyTap;
  final ValueChanged<TripSplitType> onSplitTypeSelected;
  final VoidCallback onAddMember;
  final ValueChanged<_TripMember> onRemoveMember;

  @override
  Widget build(BuildContext context) {
    final double cardPadding = MediaQuery.sizeOf(context).width < 360 ? 16 : 20;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _CreateTripPalette.cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CreateTripTextField(
            label: 'TRIP NAME',
            controller: tripNameController,
            hintText: 'e.g. Paris Weekend',
          ),
          const SizedBox(height: 24),
          _CreateTripTextField(
            label: 'DESTINATION OR ACTIVITY',
            controller: destinationController,
            hintText: 'e.g. Paris, Restaurant...',
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool stacked = constraints.maxWidth < 320;

              if (stacked) {
                return Column(
                  children: <Widget>[
                    _DateField(
                      label: 'DEPARTURE',
                      value: departureDate,
                      onTap: onDepartureTap,
                    ),
                    const SizedBox(height: 16),
                    _DateField(
                      label: 'RETURN',
                      value: returnDate,
                      onTap: onReturnTap,
                    ),
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(
                    child: _DateField(
                      label: 'DEPARTURE',
                      value: departureDate,
                      onTap: onDepartureTap,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _DateField(
                      label: 'RETURN',
                      value: returnDate,
                      onTap: onReturnTap,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          const _MutedDivider(),
          const SizedBox(height: 22),
          _SectionLabel(text: 'CURRENCY'),
          const SizedBox(height: 16),
          _CurrencySelectorField(
            currency: selectedCurrency,
            onTap: onCurrencyTap,
          ),
          const SizedBox(height: 22),
          const _MutedDivider(),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              const Expanded(child: _SectionLabel(text: 'PASSENGER LIST')),
              Text(
                '${members.length} MEMBERS',
                style: GoogleFonts.jetBrainsMono(
                  color: _CreateTripPalette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.33,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: members.map((_TripMember member) {
              return _MemberChip(
                member: member,
                onRemove: member.isCurrentUser
                    ? null
                    : () => onRemoveMember(member),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _AddMemberRow(controller: memberController, onAddMember: onAddMember),
          const SizedBox(height: 22),
          const _MutedDivider(),
          const SizedBox(height: 22),
          const _SectionLabel(text: 'SPLIT TYPE'),
          const SizedBox(height: 16),
          _SplitTypeSelector(
            selectedSplitType: selectedSplitType,
            onSelected: onSplitTypeSelected,
          ),
        ],
      ),
    );
  }
}

class _CreateTripTextField extends StatelessWidget {
  const _CreateTripTextField({
    required this.label,
    required this.controller,
    required this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(text: label),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: _CreateTripPalette.fieldFill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            cursorColor: _CreateTripPalette.orange,
            style: GoogleFonts.inter(
              color: _CreateTripPalette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: _CreateTripPalette.textPlaceholder,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String text = value == null
        ? 'mm/dd/yyyy'
        : DateFormat('MM/dd/yyyy').format(value!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(text: label),
        const SizedBox(height: 8),
        Material(
          color: _CreateTripPalette.fieldFill,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      text,
                      style: GoogleFonts.jetBrainsMono(
                        color: value == null
                            ? _CreateTripPalette.textPlaceholder
                            : _CreateTripPalette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        letterSpacing: -0.16,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: _CreateTripPalette.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencySelectorField extends StatelessWidget {
  const _CurrencySelectorField({required this.currency, required this.onTap});

  final Currency currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String flag = _currencyFlagEmoji(currency);

    return Material(
      key: const ValueKey<String>('create_trip_currency_selector'),
      color: _CreateTripPalette.fieldFill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _CreateTripPalette.cardBorder),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _CreateTripPalette.cardBorder.withValues(alpha: 0.8),
                  ),
                ),
                child: Text(
                  flag.isEmpty ? currency.code.substring(0, 1) : flag,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      currency.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _CreateTripPalette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${currency.code} | ${currency.symbol}',
                      style: GoogleFonts.jetBrainsMono(
                        color: _CreateTripPalette.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _CreateTripPalette.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.member, this.onRemove});

  final _TripMember member;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _CreateTripPalette.fieldFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _CreateTripPalette.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: member.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              member.initials,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: member.avatarTextColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              member.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: _CreateTripPalette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
          if (onRemove != null) ...<Widget>[
            const SizedBox(width: 6),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(999),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: _CreateTripPalette.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddMemberRow extends StatelessWidget {
  const _AddMemberRow({required this.controller, required this.onAddMember});

  final TextEditingController controller;
  final VoidCallback onAddMember;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stacked = constraints.maxWidth < 320;

        final Widget field = Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _CreateTripPalette.fieldFill,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onAddMember(),
              cursorColor: _CreateTripPalette.orange,
              style: GoogleFonts.inter(
                color: _CreateTripPalette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                hintText: 'Name or email',
                hintStyle: GoogleFonts.inter(
                  color: _CreateTripPalette.textPlaceholder,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        );

        final Widget button = SizedBox(
          height: 44,
          width: stacked ? double.infinity : 96,
          child: ElevatedButton(
            onPressed: onAddMember,
            style: ElevatedButton.styleFrom(
              backgroundColor: _CreateTripPalette.darkButton,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: Text(
              stacked ? 'ADD MEMBER' : 'ADD\nMEMBER',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.3,
                letterSpacing: stacked ? 0.8 : -0.2,
              ),
            ),
          ),
        );

        if (stacked) {
          return Column(
            children: <Widget>[
              SizedBox(height: 44, child: Row(children: <Widget>[field])),
              const SizedBox(height: 8),
              button,
            ],
          );
        }

        return Row(children: <Widget>[field, const SizedBox(width: 8), button]);
      },
    );
  }
}

class _SplitTypeSelector extends StatelessWidget {
  const _SplitTypeSelector({
    required this.selectedSplitType,
    required this.onSelected,
  });

  final TripSplitType selectedSplitType;
  final ValueChanged<TripSplitType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _CreateTripPalette.fieldFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: TripSplitType.values.map((TripSplitType splitType) {
          final bool selected = selectedSplitType == splitType;

          return Expanded(
            child: Material(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onSelected(splitType),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: selected
                      ? const BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        )
                      : null,
                  child: Text(
                    splitType.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.jetBrainsMono(
                      color: selected
                          ? _CreateTripPalette.textPrimary
                          : _CreateTripPalette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CreateTripPrimaryButton extends StatelessWidget {
  const _CreateTripPrimaryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const ValueKey<String>('create_trip_submit_button'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _CreateTripPalette.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: const BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 6,
                offset: Offset(0, 4),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 15,
                offset: Offset(0, 10),
                spreadRadius: -3,
              ),
            ],
          ),
          child: Text(
            'CREATE TRIP',
            style: GoogleFonts.geist(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
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
        color: _CreateTripPalette.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.45,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _MutedDivider extends StatelessWidget {
  const _MutedDivider();

  @override
  Widget build(BuildContext context) {
    return const Opacity(opacity: 0.3, child: _DashedSeparator());
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
                      color: _CreateTripPalette.separator,
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

class _TripMember {
  const _TripMember({
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.avatarTextColor,
    this.isCurrentUser = false,
  });

  final String name;
  final String initials;
  final Color avatarColor;
  final Color avatarTextColor;
  final bool isCurrentUser;

  TripParticipant toTripParticipant() {
    return TripParticipant(
      name: name,
      initials: initials,
      isCurrentUser: isCurrentUser,
    );
  }
}

class _AvatarStyle {
  const _AvatarStyle({required this.backgroundColor, required this.textColor});

  final Color backgroundColor;
  final Color textColor;
}

const List<_AvatarStyle> _memberAvatarStyles = <_AvatarStyle>[
  _AvatarStyle(
    backgroundColor: _CreateTripPalette.avatarBlue,
    textColor: _CreateTripPalette.avatarBlueText,
  ),
  _AvatarStyle(
    backgroundColor: _CreateTripPalette.avatarGreen,
    textColor: _CreateTripPalette.avatarGreenText,
  ),
  _AvatarStyle(
    backgroundColor: _CreateTripPalette.avatarSoft,
    textColor: _CreateTripPalette.avatarBlueText,
  ),
];

class _CreateTripPalette {
  static const Color background = Color(0xFFFDFCFB);
  static const Color textPrimary = Color(0xFF151B2B);
  static const Color textSecondary = Color(0xFF564338);
  static const Color textMuted = Color(0xFF404758);
  static const Color textPlaceholder = Color(0x7F564338);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color orangeText = Color(0xFF682D00);
  static const Color darkButton = Color(0xFF151B2B);
  static const Color fieldFill = Color(0xFFF8F6F2);
  static const Color cardBorder = Color(0xFFD8CFC4);
  static const Color separator = Color(0xFFA58C7F);
  static const Color avatarBlue = Color(0xFFC0C6DB);
  static const Color avatarBlueText = Color(0xFF293041);
  static const Color avatarGreen = Color(0xFF4DE082);
  static const Color avatarGreenText = Color(0xFF003919);
  static const Color avatarSoft = Color(0xFFDCE2F8);
}

String _buildInitials(String value) {
  final List<String> words = value
      .replaceAll('@', ' ')
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList();

  if (words.isEmpty) {
    return '?';
  }

  if (words.length == 1) {
    final String token = words.first;
    return token.substring(0, token.length.clamp(1, 2)).toUpperCase();
  }

  return '${words.first[0]}${words[1][0]}'.toUpperCase();
}

String _currencyFlagEmoji(Currency currency) {
  final String? flag = currency.flag;
  if (flag == null || flag.length < 2 || currency.isFlagImage) {
    return '';
  }

  return CurrencyUtils.currencyToEmoji(currency);
}
