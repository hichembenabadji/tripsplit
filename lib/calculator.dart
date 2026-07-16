import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_routes.dart';
import 'tripsplit_bottom_nav.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _displayValue = '0';
  String _inputValue = '0';
  String? _expressionText;
  String? _storedValueText;
  double? _storedValue;
  _CalculatorOperation? _pendingOperation;
  bool _shouldStartNewEntry = false;
  bool _hasError = false;
  bool _showingEvaluatedResult = false;

  void _clearAll() {
    setState(() {
      _displayValue = '0';
      _inputValue = '0';
      _expressionText = null;
      _storedValueText = null;
      _storedValue = null;
      _pendingOperation = null;
      _shouldStartNewEntry = false;
      _hasError = false;
      _showingEvaluatedResult = false;
    });
  }

  void _deleteLastCharacter() {
    if (_hasError) {
      _clearAll();
      return;
    }

    if (_shouldStartNewEntry) {
      return;
    }

    setState(() {
      if (_inputValue.length <= 1 ||
          (_inputValue.startsWith('-') && _inputValue.length == 2)) {
        _inputValue = '0';
      } else {
        _inputValue = _inputValue.substring(0, _inputValue.length - 1);
      }
      _showingEvaluatedResult = false;
      _syncDisplayState();
    });
  }

  void _enterDigit(String digit) {
    if (_hasError) {
      _clearAll();
    }

    setState(() {
      final bool isStartingFresh =
          _showingEvaluatedResult && _pendingOperation == null;

      if (isStartingFresh) {
        _expressionText = null;
      }

      if (isStartingFresh || _shouldStartNewEntry || _inputValue == '0') {
        _inputValue = digit;
        _shouldStartNewEntry = false;
      } else if (_inputValue.length < 16) {
        _inputValue += digit;
      }

      _showingEvaluatedResult = false;
      _syncDisplayState();
    });
  }

  void _enterDecimal() {
    if (_hasError) {
      _clearAll();
    }

    setState(() {
      final bool isStartingFresh =
          _showingEvaluatedResult && _pendingOperation == null;

      if (isStartingFresh) {
        _expressionText = null;
      }

      if (isStartingFresh || _shouldStartNewEntry) {
        _inputValue = '0.';
        _shouldStartNewEntry = false;
      } else if (!_inputValue.contains('.')) {
        _inputValue += '.';
      }

      _showingEvaluatedResult = false;
      _syncDisplayState();
    });
  }

  void _applyPercentage() {
    if (_hasError) {
      return;
    }

    final double result = _currentInputValue / 100;
    setState(() {
      _inputValue = _formatResult(result);
      _shouldStartNewEntry = false;
      _showingEvaluatedResult = false;
      _syncDisplayState();
    });
  }

  void _setOperation(_CalculatorOperation operation) {
    if (_hasError) {
      return;
    }

    final double currentValue = _currentInputValue;

    if (_pendingOperation != null &&
        _storedValue != null &&
        !_shouldStartNewEntry) {
      final double? result = _calculateValue(
        _storedValue!,
        currentValue,
        _pendingOperation!,
      );

      if (result == null) {
        _showError();
        return;
      }

      setState(() {
        _storedValue = result;
        _storedValueText = _formatResult(result);
        _inputValue = _storedValueText!;
        _displayValue = _storedValueText!;
        _pendingOperation = operation;
        _shouldStartNewEntry = true;
        _showingEvaluatedResult = false;
        _syncDisplayState();
      });
      return;
    }

    setState(() {
      _storedValue = currentValue;
      _storedValueText = _inputValue;
      _pendingOperation = operation;
      _shouldStartNewEntry = true;
      _showingEvaluatedResult = false;
      _syncDisplayState();
    });
  }

  void _evaluate() {
    if (_hasError || _pendingOperation == null || _storedValue == null) {
      return;
    }

    final double? result = _calculateValue(
      _storedValue!,
      _currentInputValue,
      _pendingOperation!,
    );

    if (result == null) {
      _showError();
      return;
    }

    final String expression = _buildExpressionText(
      leftValueText: _storedValueText ?? _formatResult(_storedValue!),
      operation: _pendingOperation!,
      rightValueText: _inputValue,
    );

    setState(() {
      _expressionText = expression;
      _displayValue = _formatResult(result);
      _inputValue = _displayValue;
      _storedValueText = null;
      _storedValue = null;
      _pendingOperation = null;
      _shouldStartNewEntry = true;
      _showingEvaluatedResult = true;
    });
  }

  void _showError() {
    setState(_setErrorState);
  }

  void _setErrorState() {
    _displayValue = 'Error';
    _inputValue = '0';
    _expressionText = null;
    _storedValueText = null;
    _storedValue = null;
    _pendingOperation = null;
    _shouldStartNewEntry = true;
    _hasError = true;
    _showingEvaluatedResult = false;
  }

  double? _calculateValue(
    double leftValue,
    double rightValue,
    _CalculatorOperation operation,
  ) {
    switch (operation) {
      case _CalculatorOperation.add:
        return leftValue + rightValue;
      case _CalculatorOperation.subtract:
        return leftValue - rightValue;
      case _CalculatorOperation.multiply:
        return leftValue * rightValue;
      case _CalculatorOperation.divide:
        if (rightValue == 0) {
          return null;
        }
        return leftValue / rightValue;
    }
  }

  double get _currentInputValue => double.tryParse(_inputValue) ?? 0;

  void _syncDisplayState() {
    if (_pendingOperation == null ||
        _storedValue == null ||
        _storedValueText == null) {
      if (!_showingEvaluatedResult) {
        _expressionText = null;
      }
      _displayValue = _inputValue;
      return;
    }

    if (_shouldStartNewEntry) {
      _expressionText = '${_storedValueText!} ${_pendingOperation!.symbol}';
      _displayValue = _storedValueText!;
      return;
    }

    final double? liveResult = _calculateValue(
      _storedValue!,
      _currentInputValue,
      _pendingOperation!,
    );
    if (liveResult == null) {
      _setErrorState();
      return;
    }

    _expressionText = _buildExpressionText(
      leftValueText: _storedValueText!,
      operation: _pendingOperation!,
      rightValueText: _inputValue,
    );
    _displayValue = _formatResult(liveResult);
  }

  String _buildExpressionText({
    required String leftValueText,
    required _CalculatorOperation operation,
    required String rightValueText,
  }) {
    return '$leftValueText ${operation.symbol} $rightValueText';
  }

  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) {
      return 'Error';
    }

    final String rawValue = value.toStringAsFixed(10);
    return rawValue.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = MediaQuery.sizeOf(context).width < 360
        ? 14
        : 16;

    return Scaffold(
      key: const ValueKey<String>('calculator_screen'),
      backgroundColor: _CalculatorPalette.background,
      bottomNavigationBar: TripSplitBottomNav(
        activeTab: TripSplitBottomNavTab.calculator,
        backgroundColor: _CalculatorPalette.background,
        separatorColor: _CalculatorPalette.separator,
        activeFillColor: _CalculatorPalette.orange,
        activeTextColor: _CalculatorPalette.orangeText,
        inactiveTextColor: _CalculatorPalette.textMuted,
        onTripsTap: () => Navigator.of(
          context,
        ).popUntil((Route<dynamic> route) => route.isFirst),
        onProfileTap: () => Navigator.of(
          context,
        ).pushNamed(TripSplitRoutes.profile),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const _CalculatorHeader(),
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
                          _CalculatorDisplay(
                            expression: _expressionText,
                            value: _displayValue,
                            hasError: _hasError,
                          ),
                          const SizedBox(height: 24),
                          _CalculatorKeypad(
                            onDigitTap: _enterDigit,
                            onClearTap: _clearAll,
                            onDeleteTap: _deleteLastCharacter,
                            onPercentTap: _applyPercentage,
                            onDecimalTap: _enterDecimal,
                            onEqualsTap: _evaluate,
                            onOperationTap: _setOperation,
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
    );
  }
}

enum _CalculatorOperation {
  add('+'),
  subtract('-'),
  multiply('×'),
  divide('÷');

  const _CalculatorOperation(this.symbol);

  final String symbol;
}

class _CalculatorHeader extends StatelessWidget {
  const _CalculatorHeader();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _CalculatorPalette.background,
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
                        color: _CalculatorPalette.orange,
                        colorBlendMode: BlendMode.srcIn,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'TRIPSPLIT',
                        style: GoogleFonts.geist(
                          color: _CalculatorPalette.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const _CalculatorProfileAvatar(),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _CalculatorDashedSeparator(),
          ),
        ],
      ),
    );
  }
}

class _CalculatorProfileAvatar extends StatelessWidget {
  const _CalculatorProfileAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _CalculatorPalette.separator),
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

class _CalculatorDisplay extends StatelessWidget {
  const _CalculatorDisplay({
    required this.expression,
    required this.value,
    required this.hasError,
  });

  final String? expression;
  final String value;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double height = constraints.maxWidth < 360 ? 220 : 250;
        final double fontSize = value.length > 10 ? 44 : 54;

        return Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            color: _CalculatorPalette.displayFill,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _CalculatorPalette.borderSoft),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (expression != null && expression!.isNotEmpty) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      expression!,
                      key: const ValueKey<String>('calculator_expression_text'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        color: _CalculatorPalette.textMuted,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  key: const ValueKey<String>('calculator_display_text'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.geist(
                    color: hasError
                        ? _CalculatorPalette.red
                        : _CalculatorPalette.displayText,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    letterSpacing: -1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CalculatorKeypad extends StatelessWidget {
  const _CalculatorKeypad({
    required this.onDigitTap,
    required this.onClearTap,
    required this.onDeleteTap,
    required this.onPercentTap,
    required this.onDecimalTap,
    required this.onEqualsTap,
    required this.onOperationTap,
  });

  final ValueChanged<String> onDigitTap;
  final VoidCallback onClearTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onPercentTap;
  final VoidCallback onDecimalTap;
  final VoidCallback onEqualsTap;
  final ValueChanged<_CalculatorOperation> onOperationTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double gap = 8;
        final double buttonWidth = (constraints.maxWidth - gap * 3) / 4;
        final double buttonHeight = buttonWidth < 75 ? 52 : 56;
        final double zeroWidth = buttonWidth * 2 + gap;

        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _CalculatorButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  label: 'C',
                  foregroundColor: _CalculatorPalette.textPrimary,
                  onTap: onClearTap,
                ),
                const SizedBox(width: gap),
                _CalculatorButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  icon: Icons.backspace_outlined,
                  foregroundColor: _CalculatorPalette.textPrimary,
                  onTap: onDeleteTap,
                ),
                const SizedBox(width: gap),
                _CalculatorButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  label: '%',
                  foregroundColor: _CalculatorPalette.displayText,
                  onTap: onPercentTap,
                ),
                const SizedBox(width: gap),
                _CalculatorButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  label: _CalculatorOperation.divide.symbol,
                  foregroundColor: _CalculatorPalette.displayText,
                  onTap: () => onOperationTap(_CalculatorOperation.divide),
                ),
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: <Widget>[
                _digitButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  digit: '7',
                ),
                const SizedBox(width: gap),
                _digitButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  digit: '8',
                ),
                const SizedBox(width: gap),
                _digitButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  digit: '9',
                ),
                const SizedBox(width: gap),
                _CalculatorButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  label: _CalculatorOperation.multiply.symbol,
                  foregroundColor: _CalculatorPalette.displayText,
                  onTap: () => onOperationTap(_CalculatorOperation.multiply),
                ),
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: <Widget>[
                _digitButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  digit: '4',
                ),
                const SizedBox(width: gap),
                _digitButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  digit: '5',
                ),
                const SizedBox(width: gap),
                _digitButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  digit: '6',
                ),
                const SizedBox(width: gap),
                _CalculatorButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  label: _CalculatorOperation.subtract.symbol,
                  foregroundColor: _CalculatorPalette.displayText,
                  onTap: () => onOperationTap(_CalculatorOperation.subtract),
                ),
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: <Widget>[
                _digitButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  digit: '1',
                ),
                const SizedBox(width: gap),
                _digitButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  digit: '2',
                ),
                const SizedBox(width: gap),
                _digitButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  digit: '3',
                ),
                const SizedBox(width: gap),
                _CalculatorButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  label: _CalculatorOperation.add.symbol,
                  foregroundColor: _CalculatorPalette.displayText,
                  onTap: () => onOperationTap(_CalculatorOperation.add),
                ),
              ],
            ),
            const SizedBox(height: gap),
            Row(
              children: <Widget>[
                _digitButton(
                  width: zeroWidth,
                  height: buttonHeight,
                  digit: '0',
                ),
                const SizedBox(width: gap),
                _CalculatorButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  label: '.',
                  foregroundColor: _CalculatorPalette.textPrimary,
                  onTap: onDecimalTap,
                ),
                const SizedBox(width: gap),
                _CalculatorButton(
                  width: buttonWidth,
                  height: buttonHeight,
                  label: '=',
                  backgroundColor: _CalculatorPalette.orange,
                  foregroundColor: Colors.white,
                  onTap: onEqualsTap,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _digitButton({
    required double width,
    required double height,
    required String digit,
  }) {
    return _CalculatorButton(
      width: width,
      height: height,
      label: digit,
      foregroundColor: _CalculatorPalette.textPrimary,
      onTap: () => onDigitTap(digit),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({
    required this.width,
    required this.height,
    required this.foregroundColor,
    required this.onTap,
    this.label,
    this.icon,
    this.backgroundColor = Colors.white,
  }) : assert(label != null || icon != null);

  final double width;
  final double height;
  final String? label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _CalculatorPalette.borderSoft),
            ),
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 20, color: foregroundColor)
                  : Text(
                      label!,
                      style: GoogleFonts.geist(
                        color: foregroundColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorDashedSeparator extends StatelessWidget {
  const _CalculatorDashedSeparator();

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
                      color: _CalculatorPalette.separator,
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

class _CalculatorPalette {
  static const Color background = Color(0xFFFDFAF6);
  static const Color displayFill = Color(0xFFFDF1E8);
  static const Color borderSoft = Color(0xFFD9C4B8);
  static const Color separator = Color(0xFFA58C7F);
  static const Color textPrimary = Color(0xFF151B2B);
  static const Color textMuted = Color(0xFF564338);
  static const Color displayText = Color(0xFF9A4600);
  static const Color orange = Color(0xFFFF8A3D);
  static const Color orangeText = Color(0xFF682D00);
  static const Color red = Color(0xFFBA1A1A);
}
