import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'app_routes.dart';
import 'trip_store.dart';
import 'tripsplit_bottom_nav.dart';

final Map<String, NumberFormat> _createExpenseCurrencyFormatters =
    <String, NumberFormat>{};

String _formatCreateExpenseCurrency(
  double amount, {
  required String currencyCode,
  required String currencySymbol,
}) {
  final String formatterKey = '$currencyCode::$currencySymbol';
  final NumberFormat formatter =
      _createExpenseCurrencyFormatters[formatterKey] ??= NumberFormat.currency(
        locale: 'en_US',
        name: currencyCode,
        symbol: currencySymbol,
        decimalDigits: 2,
      );

  return formatter.format(amount);
}

void _openCalculatorFromCreateExpense(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.calculator);
}

void _openProfileFromCreateExpense(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.profile);
}

class CreateExpenseScreen extends StatefulWidget {
  const CreateExpenseScreen({super.key, required this.tripId});

  final String tripId;

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  ExpenseSplitType _selectedSplitType = ExpenseSplitType.equally;
  final Set<String> _selectedBeneficiaryKeys = <String>{};
  String? _paidByKey;
  bool _didInitializeTripState = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInitializeTripState) {
      return;
    }

    final TripSummary? trip = TripStoreScope.read(
      context,
    ).findTripById(widget.tripId);
    if (trip == null) {
      return;
    }

    final TripParticipant paidByParticipant =
        trip.participants.cast<TripParticipant?>().firstWhere(
          (TripParticipant? participant) => participant?.isCurrentUser ?? false,
          orElse: () =>
              trip.participants.isNotEmpty ? trip.participants.first : null,
        ) ??
        trip.participants.first;

    _paidByKey = _participantKey(paidByParticipant);
    _selectedBeneficiaryKeys.addAll(trip.participants.map(_participantKey));
    _didInitializeTripState = true;
  }

  void _toggleBeneficiary(TripParticipant participant) {
    final String key = _participantKey(participant);

    setState(() {
      if (_selectedBeneficiaryKeys.contains(key)) {
        _selectedBeneficiaryKeys.remove(key);
      } else {
        _selectedBeneficiaryKeys.add(key);
      }
    });
  }

  double _parsedAmount() {
    final String rawValue = _amountController.text.trim().replaceAll(',', '.');
    return double.tryParse(rawValue) ?? 0;
  }

  void _submitExpense(TripSummary trip) {
    FocusManager.instance.primaryFocus?.unfocus();

    final String title = _descriptionController.text.trim();
    final double amount = _parsedAmount();
    final Map<String, TripParticipant> participantMap =
        <String, TripParticipant>{
          for (final TripParticipant participant in trip.participants)
            _participantKey(participant): participant,
        };

    final TripParticipant? paidBy = _paidByKey == null
        ? null
        : participantMap[_paidByKey!];
    final List<TripParticipant> beneficiaries = trip.participants
        .where(
          (TripParticipant participant) =>
              _selectedBeneficiaryKeys.contains(_participantKey(participant)),
        )
        .toList(growable: false);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an expense description first.')),
      );
      return;
    }

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid declared amount.')),
      );
      return;
    }

    if (paidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose who paid for this expense.')),
      );
      return;
    }

    if (beneficiaries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one beneficiary.')),
      );
      return;
    }

    TripStoreScope.read(context).addExpense(
      tripId: trip.id,
      title: title,
      amount: amount,
      paidBy: paidBy,
      splitType: _selectedSplitType,
      beneficiaries: beneficiaries,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final TripSummary? trip = TripStoreScope.of(
      context,
    ).findTripById(widget.tripId);
    final Size screenSize = MediaQuery.sizeOf(context);
    final double horizontalPadding = screenSize.width < 360 ? 14 : 16;

    if (trip == null) {
      return Scaffold(
        backgroundColor: _CreateExpensePalette.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'This trip could not be found.',
                textAlign: TextAlign.center,
                style: GoogleFonts.geist(
                  color: _CreateExpensePalette.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final Map<String, TripParticipant> participantMap =
        <String, TripParticipant>{
          for (final TripParticipant participant in trip.participants)
            _participantKey(participant): participant,
        };
    final double amount = _parsedAmount();
    final int beneficiaryCount = _selectedBeneficiaryKeys.length;
    final double amountPerMember = beneficiaryCount == 0
        ? 0
        : amount / beneficiaryCount;

    return Scaffold(
      key: const ValueKey<String>('create_expense_screen'),
      backgroundColor: _CreateExpensePalette.background,
      bottomNavigationBar: TripSplitBottomNav(
        activeTab: TripSplitBottomNavTab.trips,
        backgroundColor: _CreateExpensePalette.background,
        separatorColor: _CreateExpensePalette.cardBorder,
        activeFillColor: _CreateExpensePalette.orange,
        activeTextColor: _CreateExpensePalette.orangeText,
        inactiveTextColor: _CreateExpensePalette.textSecondary,
        onCalculatorTap: () => _openCalculatorFromCreateExpense(context),
        onProfileTap: () => _openProfileFromCreateExpense(context),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            _CreateExpenseHeader(
              onClose: () => Navigator.of(context).maybePop(),
              onSave: () => _submitExpense(trip),
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
                          _ExpenseFormHero(trip: trip),
                          const SizedBox(height: 20),
                          _ExpenseFormCard(
                            trip: trip,
                            descriptionController: _descriptionController,
                            amountController: _amountController,
                            paidByKey: _paidByKey,
                            participantMap: participantMap,
                            selectedSplitType: _selectedSplitType,
                            selectedBeneficiaryKeys: _selectedBeneficiaryKeys,
                            amountPerMember: amountPerMember,
                            onPaidByChanged: (String? participantKey) {
                              setState(() {
                                _paidByKey = participantKey;
                              });
                            },
                            onSplitTypeChanged: (ExpenseSplitType splitType) {
                              setState(() {
                                _selectedSplitType = splitType;
                              });
                            },
                            onBeneficiaryToggled: _toggleBeneficiary,
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
                12,
                horizontalPadding,
                12,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _CreateExpensePrimaryButton(
                    onPressed: () => _submitExpense(trip),
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

class _CreateExpenseHeader extends StatelessWidget {
  const _CreateExpenseHeader({required this.onClose, required this.onSave});

  final VoidCallback onClose;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _CreateExpensePalette.background,
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
                      onTap: onClose,
                      child: const Icon(
                        Icons.close_rounded,
                        color: _CreateExpensePalette.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'TRIPSPLIT',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        color: _CreateExpensePalette.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onSave,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(52, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Save',
                      style: GoogleFonts.geist(
                        color: _CreateExpensePalette.saveText,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
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

class _ExpenseFormHero extends StatelessWidget {
  const _ExpenseFormHero({required this.trip});

  final TripSummary trip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'EXPENSE DECLARATION',
          style: GoogleFonts.jetBrainsMono(
            color: _CreateExpensePalette.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            height: 1.45,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'FORM NO: ${_buildFormNumber(trip)}',
          style: GoogleFonts.jetBrainsMono(
            color: _CreateExpensePalette.textMuted.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.33,
            letterSpacing: -0.6,
          ),
        ),
      ],
    );
  }
}

class _ExpenseFormCard extends StatelessWidget {
  const _ExpenseFormCard({
    required this.trip,
    required this.descriptionController,
    required this.amountController,
    required this.paidByKey,
    required this.participantMap,
    required this.selectedSplitType,
    required this.selectedBeneficiaryKeys,
    required this.amountPerMember,
    required this.onPaidByChanged,
    required this.onSplitTypeChanged,
    required this.onBeneficiaryToggled,
  });

  final TripSummary trip;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final String? paidByKey;
  final Map<String, TripParticipant> participantMap;
  final ExpenseSplitType selectedSplitType;
  final Set<String> selectedBeneficiaryKeys;
  final double amountPerMember;
  final ValueChanged<String?> onPaidByChanged;
  final ValueChanged<ExpenseSplitType> onSplitTypeChanged;
  final ValueChanged<TripParticipant> onBeneficiaryToggled;

  @override
  Widget build(BuildContext context) {
    final double cardPadding = MediaQuery.sizeOf(context).width < 360 ? 14 : 16;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _CreateExpensePalette.cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ExpenseTextField(
            label: 'DESCRIPTION OF EXPENSE',
            controller: descriptionController,
            hintText: 'e.g. Dinner at Tokyo Hub',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool stacked = constraints.maxWidth < 320;

              final Widget amountField = Expanded(
                child: _AmountField(
                  label: 'DECLARED AMOUNT',
                  controller: amountController,
                  currencySymbol: trip.currencySymbol,
                ),
              );
              final Widget paidByField = Expanded(
                child: _PaidByField(
                  label: 'PAID BY',
                  participants: trip.participants,
                  selectedKey: paidByKey,
                  onChanged: onPaidByChanged,
                ),
              );

              if (stacked) {
                return Column(
                  children: <Widget>[
                    amountField,
                    const SizedBox(height: 16),
                    paidByField,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  amountField,
                  const SizedBox(width: 16),
                  paidByField,
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'SPLIT METHOD',
            style: GoogleFonts.geist(
              color: _CreateExpensePalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _SplitMethodSelector(
            selectedSplitType: selectedSplitType,
            onSelected: onSplitTypeChanged,
          ),
          const SizedBox(height: 20),
          Text(
            'BENEFICIARY CHECKLIST',
            style: GoogleFonts.geist(
              color: _CreateExpensePalette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...trip.participants.map((TripParticipant participant) {
            final bool selected = selectedBeneficiaryKeys.contains(
              _participantKey(participant),
            );

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BeneficiaryTile(
                participant: participant,
                selected: selected,
                onTap: () => onBeneficiaryToggled(participant),
              ),
            );
          }),
          const SizedBox(height: 8),
          _CalculationCard(trip: trip, amountPerMember: amountPerMember),
        ],
      ),
    );
  }
}

class _ExpenseTextField extends StatelessWidget {
  const _ExpenseTextField({
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _CreateExpensePalette.inputBorder),
          ),
          child: TextField(
            controller: controller,
            cursorColor: _CreateExpensePalette.orange,
            style: GoogleFonts.inter(
              color: _CreateExpensePalette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              hintText: hintText,
              hintStyle: GoogleFonts.inter(
                color: _CreateExpensePalette.placeholder,
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

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.label,
    required this.controller,
    required this.currencySymbol,
  });

  final String label;
  final TextEditingController controller;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(text: label),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _CreateExpensePalette.inputBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            cursorColor: _CreateExpensePalette.orange,
            style: GoogleFonts.jetBrainsMono(
              color: _CreateExpensePalette.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              prefixText: '$currencySymbol ',
              prefixStyle: GoogleFonts.jetBrainsMono(
                color: _CreateExpensePalette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              hintText: '0.00',
              hintStyle: GoogleFonts.jetBrainsMono(
                color: _CreateExpensePalette.placeholder,
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

class _PaidByField extends StatelessWidget {
  const _PaidByField({
    required this.label,
    required this.participants,
    required this.selectedKey,
    required this.onChanged,
  });

  final String label;
  final List<TripParticipant> participants;
  final String? selectedKey;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionLabel(text: label),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _CreateExpensePalette.inputBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedKey,
              isExpanded: true,
              icon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _CreateExpensePalette.textMuted,
                ),
              ),
              padding: const EdgeInsets.only(left: 12, right: 4),
              style: GoogleFonts.inter(
                color: _CreateExpensePalette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              items: participants
                  .map((TripParticipant participant) {
                    return DropdownMenuItem<String>(
                      value: _participantKey(participant),
                      child: Text(
                        participant.isCurrentUser ? 'You' : participant.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  })
                  .toList(growable: false),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _SplitMethodSelector extends StatelessWidget {
  const _SplitMethodSelector({
    required this.selectedSplitType,
    required this.onSelected,
  });

  final ExpenseSplitType selectedSplitType;
  final ValueChanged<ExpenseSplitType> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 340) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExpenseSplitType.values
                .map((ExpenseSplitType splitType) {
                  final bool selected = selectedSplitType == splitType;
                  return _SplitMethodChip(
                    splitType: splitType,
                    selected: selected,
                    onTap: () => onSelected(splitType),
                  );
                })
                .toList(growable: false),
          );
        }

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _CreateExpensePalette.segmentFill,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: ExpenseSplitType.values
                .map((ExpenseSplitType splitType) {
                  final bool selected = selectedSplitType == splitType;
                  return Expanded(
                    child: Material(
                      color: selected
                          ? _CreateExpensePalette.orange
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => onSelected(splitType),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            splitType.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: selected
                                  ? _CreateExpensePalette.orangeText
                                  : _CreateExpensePalette.textMuted,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                })
                .toList(growable: false),
          ),
        );
      },
    );
  }
}

class _SplitMethodChip extends StatelessWidget {
  const _SplitMethodChip({
    required this.splitType,
    required this.selected,
    required this.onTap,
  });

  final ExpenseSplitType splitType;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? _CreateExpensePalette.orange
          : _CreateExpensePalette.segmentFill,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            splitType.label,
            style: GoogleFonts.inter(
              color: selected
                  ? _CreateExpensePalette.orangeText
                  : _CreateExpensePalette.textMuted,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _BeneficiaryTile extends StatelessWidget {
  const _BeneficiaryTile({
    required this.participant,
    required this.selected,
    required this.onTap,
  });

  final TripParticipant participant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _CreateExpensePalette.cardBorder),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _beneficiaryAvatarColor(participant),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  participant.dashboardLabel,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    color: participant.isCurrentUser
                        ? Colors.white
                        : _CreateExpensePalette.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  participant.isCurrentUser ? 'You' : participant.name,
                  style: GoogleFonts.inter(
                    color: participant.isCurrentUser
                        ? _CreateExpensePalette.orangeText
                        : _CreateExpensePalette.textPrimary,
                    fontSize: 16,
                    fontWeight: participant.isCurrentUser
                        ? FontWeight.w600
                        : FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ),
              Checkbox(
                value: selected,
                onChanged: (_) => onTap(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: _CreateExpensePalette.cardBorder),
                activeColor: _CreateExpensePalette.green,
                checkColor: Colors.white,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalculationCard extends StatelessWidget {
  const _CalculationCard({required this.trip, required this.amountPerMember});

  final TripSummary trip;
  final double amountPerMember;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _DashedRoundedRectPainter(
        color: _CreateExpensePalette.dashedBorder,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _CreateExpensePalette.summaryFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'CALCULATION PER MEMBER',
                    style: GoogleFonts.jetBrainsMono(
                      color: _CreateExpensePalette.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 22,
                    color: _CreateExpensePalette.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatCreateExpenseCurrency(
                amountPerMember,
                currencyCode: trip.currencyCode,
                currencySymbol: trip.currencySymbol,
              ),
              style: GoogleFonts.geist(
                color: _CreateExpensePalette.saveText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: _CreateExpensePalette.cardBorder),
            const SizedBox(height: 14),
            Text(
              'Select participants and amount to calculate\nautomatically.',
              style: GoogleFonts.inter(
                color: _CreateExpensePalette.textMuted.withValues(alpha: 0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateExpensePrimaryButton extends StatelessWidget {
  const _CreateExpensePrimaryButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        key: const ValueKey<String>('create_expense_submit_button'),
        onPressed: onPressed,
        icon: const Icon(
          Icons.workspace_premium_outlined,
          color: _CreateExpensePalette.orangeText,
          size: 20,
        ),
        label: Text(
          'CERTIFY EXPENSE',
          style: GoogleFonts.geist(
            color: _CreateExpensePalette.orangeText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 1.0,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _CreateExpensePalette.orange,
          foregroundColor: _CreateExpensePalette.orangeText,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: _CreateExpensePalette.textMuted,
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
                      color: _CreateExpensePalette.cardBorder,
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

class _DashedRoundedRectPainter extends CustomPainter {
  const _DashedRoundedRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const Radius radius = Radius.circular(12);
    const double dashLength = 6;
    const double gapLength = 4;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(Offset.zero & size, radius);
    final Path path = Path()..addRRect(rrect);
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedRectPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

String _participantKey(TripParticipant participant) {
  return '${participant.name}::${participant.initials}::${participant.isCurrentUser}';
}

String _buildFormNumber(TripSummary trip) {
  final int serialNumber = trip.id.hashCode.abs() % 1000;
  final String serial = serialNumber.toString().padLeft(3, '0');
  final String compactDestination = trip.destination.toUpperCase().replaceAll(
    RegExp(r'[^A-Z0-9]'),
    '',
  );
  final String suffix = compactDestination.isEmpty
      ? 'TRIP'
      : compactDestination.substring(0, math.min(5, compactDestination.length));

  return 'TS-$serial-$suffix';
}

Color _beneficiaryAvatarColor(TripParticipant participant) {
  if (participant.isCurrentUser) {
    return _CreateExpensePalette.orange;
  }

  final int seed = participant.name.hashCode.abs() % 3;
  switch (seed) {
    case 0:
      return const Color(0xFFDCE2F8);
    case 1:
      return const Color(0xFFE8E4DE);
    default:
      return const Color(0xFFC9D0E4);
  }
}

class _CreateExpensePalette {
  static const Color background = Color(0xFFFCF8F5);
  static const Color summaryFill = Color(0xFFF8F2EC);
  static const Color segmentFill = Color(0xFFF0EBE6);
  static const Color cardBorder = Color(0xFFE7E0DB);
  static const Color inputBorder = Color(0xFFD5C2B6);
  static const Color dashedBorder = Color(0xFFD5C2B6);
  static const Color textPrimary = Color(0xFF151B2B);
  static const Color textSecondary = Color(0xFF404758);
  static const Color textMuted = Color(0xFF53433A);
  static const Color placeholder = Color(0xFF6B7280);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color orangeText = Color(0xFF321200);
  static const Color saveText = Color(0xFF9A4600);
  static const Color green = Color(0xFF22C268);
}
