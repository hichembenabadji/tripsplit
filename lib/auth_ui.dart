import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class TripSplitAuthPage extends StatelessWidget {
  const TripSplitAuthPage({
    super.key,
    required this.card,
    this.footer,
    this.onBack,
  });

  final Widget card;
  final Widget? footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final AuthColorTokens colors = appColors.auth;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            TripSplitAuthHeader(onBack: onBack),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: <Widget>[
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: card,
                    ),
                  ),
                  if (footer != null) ...<Widget>[
                    const SizedBox(height: 32),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: footer!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TripSplitAuthHeader extends StatelessWidget {
  const TripSplitAuthHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final AuthColorTokens colors = appColors.auth;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.dividerSoft)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 36,
              height: 36,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
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
                    color: colors.orangeDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}

class TripSplitAuthCard extends StatelessWidget {
  const TripSplitAuthCard({
    super.key,
    required this.title,
    required this.description,
    required this.children,
    this.footer,
  });

  final String title;
  final String description;
  final List<Widget> children;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final AuthColorTokens colors = appColors.auth;
    final SharedColorTokens shared = appColors.shared;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: shared.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shared.shadowSoft,
            blurRadius: 30,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 23, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.geist(
                    color: colors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: colors.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Divider(color: colors.dividerSoft, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: ListBody(children: children),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }
}

class TripSplitFieldLabel extends StatelessWidget {
  const TripSplitFieldLabel({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AuthColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.auth;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: colors.orangeDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.45,
              letterSpacing: 1.1,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class TripSplitInputSurface extends StatelessWidget {
  const TripSplitInputSurface({
    super.key,
    required this.child,
    this.borderColor,
  });

  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final AuthColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.auth;

    return Container(
      decoration: BoxDecoration(
        color: colors.fieldFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? colors.fieldBorder),
      ),
      child: child,
    );
  }
}

class TripSplitLabeledTextField extends StatelessWidget {
  const TripSplitLabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.trailing,
    this.keyboardType,
    this.autofillHints,
    this.onChanged,
    this.obscureText = false,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = false,
    this.enableSuggestions = true,
    this.supportingText,
    this.supportingTextColor,
    this.borderColor,
  });

  final String label;
  final String hintText;
  final TextEditingController? controller;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? supportingText;
  final Color? supportingTextColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final AuthColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.auth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TripSplitFieldLabel(label: label, trailing: trailing),
        const SizedBox(height: 4),
        TripSplitInputSurface(
          borderColor: borderColor ?? colors.fieldBorder,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            obscureText: obscureText,
            obscuringCharacter: '*',
            textInputAction: textInputAction,
            textCapitalization: textCapitalization,
            autocorrect: autocorrect,
            enableSuggestions: enableSuggestions,
            cursorColor: colors.orangeDark,
            style: GoogleFonts.jetBrainsMono(
              color: colors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: GoogleFonts.jetBrainsMono(
                color: colors.textPlaceholder,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
            onChanged: onChanged,
          ),
        ),
        if (supportingText != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            supportingText!,
            style: GoogleFonts.jetBrainsMono(
              color: supportingTextColor ?? colors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class TripSplitPrimaryButton extends StatelessWidget {
  const TripSplitPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.buttonKey,
  });

  final String label;
  final VoidCallback? onPressed;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final AuthColorTokens colors = appColors.auth;
    final SharedColorTokens shared = appColors.shared;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: buttonKey,
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.buttonFill,
          foregroundColor: shared.white,
          disabledBackgroundColor: colors.buttonDisabledFill,
          disabledForegroundColor: colors.buttonDisabledText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadowColor: shared.transparent,
          textStyle: GoogleFonts.geist(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            boxShadow: isEnabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: shared.shadowStrong,
                      blurRadius: 10,
                      offset: Offset(0, 8),
                      spreadRadius: -6,
                    ),
                    BoxShadow(
                      color: shared.shadowStrong,
                      blurRadius: 25,
                      offset: Offset(0, 20),
                      spreadRadius: -5,
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Container(alignment: Alignment.center, child: Text(label)),
        ),
      ),
    );
  }
}

class TripSplitSectionLabelDivider extends StatelessWidget {
  const TripSplitSectionLabelDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final AuthColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.auth;

    return Row(
      children: <Widget>[
        Expanded(child: Divider(color: colors.dividerSoft, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: colors.textPlaceholder,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.dividerSoft, thickness: 1)),
      ],
    );
  }
}

class TripSplitFooterPrompt extends StatelessWidget {
  const TripSplitFooterPrompt({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onAction,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final AuthColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.auth;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.footerFill,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(top: BorderSide(color: colors.footerBorder)),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: <Widget>[
          Text(
            prompt,
            style: GoogleFonts.inter(
              color: colors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: _linkButtonStyle(colors.orangeDark),
            child: Text(
              actionLabel,
              style: GoogleFonts.jetBrainsMono(
                color: colors.orangeDark,
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

class TripSplitPrivacyFooter extends StatelessWidget {
  const TripSplitPrivacyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.auth;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/icons/lock.png',
              width: 12,
              height: 12,
              color: colors.textPlaceholder,
              colorBlendMode: BlendMode.srcIn,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'YOUR TRIP DATA STAYS PRIVATE AND ENCRYPTED.',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  color: colors.textPlaceholder,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 4,
          children: <Widget>[
            TextButton(
              onPressed: () {},
              style: _linkButtonStyle(colors.footerText),
              child: Text(
                'PRIVACY POLICY',
                style: GoogleFonts.jetBrainsMono(
                  color: colors.footerText,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: _linkButtonStyle(colors.footerText),
              child: Text(
                'TERMS OF SERVICE',
                style: GoogleFonts.jetBrainsMono(
                  color: colors.footerText,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

ButtonStyle _linkButtonStyle(Color color) {
  return TextButton.styleFrom(
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    foregroundColor: color,
  );
}
