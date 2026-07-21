import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_routes.dart';
import 'auth_ui.dart';

void _handleSuccessfulSignIn(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  assert(() {
    debugPrint('Sign in pressed: navigating to DashboardScreen');
    return true;
  }());

  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
    TripSplitRoutes.dashboard,
    (Route<dynamic> route) => false,
  );
}

void _openCreateAccount(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.createAccount);
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const TripSplitAuthPage(
      card: _SignInCard(),
      footer: TripSplitPrivacyFooter(),
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard();

  @override
  Widget build(BuildContext context) {
    final AuthColorTokens colors = Theme.of(
      context,
    ).extension<AppColors>()!.auth;

    return TripSplitAuthCard(
      title: 'Welcome',
      description: 'Sign in to manage trips, expenses\nand settlements.',
      footer: TripSplitFooterPrompt(
        prompt: 'New to TripSplit?',
        actionLabel: 'Create account',
        onAction: () => _openCreateAccount(context),
      ),
      children: <Widget>[
        TripSplitLabeledTextField(
          label: 'EMAIL',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const <String>[AutofillHints.email],
          hintText: 'name@trip.com',
        ),
        const SizedBox(height: 24),
        TripSplitLabeledTextField(
          label: 'PASSWORD',
          hintText: '********',
          obscureText: true,
          enableSuggestions: false,
          trailing: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: colors.orangeDark,
            ),
            child: Text(
              'Forgot password?',
              style: GoogleFonts.jetBrainsMono(
                color: colors.orangeDark,
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TripSplitPrimaryButton(
          label: 'Sign In',
          buttonKey: const ValueKey<String>('sign_in_button'),
          onPressed: () => _handleSuccessfulSignIn(context),
        ),
        const SizedBox(height: 28),
        const TripSplitSectionLabelDivider(label: 'OR CONTINUE WITH'),
        const SizedBox(height: 24),
        const _SocialActions(),
      ],
    );
  }
}

class _SocialActions extends StatelessWidget {
  const _SocialActions();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double availableWidth = constraints.maxWidth;
        final double buttonWidth = availableWidth < 320
            ? availableWidth
            : (availableWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 12,
          children: <Widget>[
            SizedBox(
              width: buttonWidth,
              child: const _SocialButton(
                iconPath: 'assets/icons/google.png',
                label: 'GOOGLE',
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: const _SocialButton(
                iconPath: 'assets/icons/apple.png',
                label: 'APPLE',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.iconPath, required this.label});

  final String iconPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final AuthColorTokens colors = appColors.auth;
    final SharedColorTokens shared = appColors.shared;

    return Material(
      color: shared.cardBackground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: shared.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.socialButtonBorder),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: shared.shadowSubtle,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(iconPath, width: 20, height: 20, fit: BoxFit.contain),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: colors.socialButtonText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
