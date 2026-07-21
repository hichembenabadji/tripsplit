import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_auth_controller.dart';
import 'app_colors.dart';
import 'app_routes.dart';
import 'auth_service.dart';
import 'auth_ui.dart';

final RegExp _signInEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

void _openCreateAccount(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  Navigator.of(context).pushNamed(TripSplitRoutes.createAccount);
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSigningIn = false;
  bool _isSigningInWithGoogle = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _trimmedEmail => _emailController.text.trim();
  String get _password => _passwordController.text;
  bool get _isBusy => _isSigningIn || _isSigningInWithGoogle;

  void _showMessage(String message) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToDashboard() {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      TripSplitRoutes.dashboard,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _handleEmailSignIn() async {
    if (_isBusy) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (_trimmedEmail.isEmpty || _password.isEmpty) {
      _showMessage('Enter your email and password to sign in.');
      return;
    }

    if (!_signInEmailPattern.hasMatch(_trimmedEmail)) {
      _showMessage('Enter a valid email address and try again.');
      return;
    }

    setState(() {
      _isSigningIn = true;
    });

    try {
      await AppAuthScope.read(
        context,
      ).signInWithEmailAndPassword(_trimmedEmail, _password);

      if (!mounted) {
        return;
      }

      _navigateToDashboard();
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isBusy) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isSigningInWithGoogle = true;
    });

    try {
      await AppAuthScope.read(context).signInWithGoogle();

      if (!mounted) {
        return;
      }

      _navigateToDashboard();
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() {
          _isSigningInWithGoogle = false;
        });
      }
    }
  }

  void _showAppleComingSoon() {
    FocusManager.instance.primaryFocus?.unfocus();
    _showMessage('Apple Sign-In is coming soon.');
  }

  void _showForgotPasswordSoon() {
    FocusManager.instance.primaryFocus?.unfocus();
    _showMessage('Password reset is coming soon.');
  }

  @override
  Widget build(BuildContext context) {
    return TripSplitAuthPage(
      card: _SignInCard(
        emailController: _emailController,
        passwordController: _passwordController,
        isBusy: _isBusy,
        onEmailSignIn: _handleEmailSignIn,
        onGoogleSignIn: _handleGoogleSignIn,
        onAppleTap: _showAppleComingSoon,
        onForgotPassword: _showForgotPasswordSoon,
      ),
      footer: const TripSplitPrivacyFooter(),
    );
  }
}

class _SignInCard extends StatelessWidget {
  const _SignInCard({
    required this.emailController,
    required this.passwordController,
    required this.isBusy,
    required this.onEmailSignIn,
    required this.onGoogleSignIn,
    required this.onAppleTap,
    required this.onForgotPassword,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isBusy;
  final VoidCallback onEmailSignIn;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleTap;
  final VoidCallback onForgotPassword;

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
        AutofillGroup(
          child: Column(
            children: <Widget>[
              TripSplitLabeledTextField(
                label: 'EMAIL',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.email],
                hintText: 'name@trip.com',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),
              TripSplitLabeledTextField(
                label: 'PASSWORD',
                controller: passwordController,
                hintText: '********',
                obscureText: true,
                enableSuggestions: false,
                autofillHints: const <String>[AutofillHints.password],
                textInputAction: TextInputAction.done,
                trailing: TextButton(
                  onPressed: isBusy ? null : onForgotPassword,
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
            ],
          ),
        ),
        const SizedBox(height: 20),
        TripSplitPrimaryButton(
          label: 'Sign In',
          buttonKey: const ValueKey<String>('sign_in_button'),
          onPressed: isBusy ? null : onEmailSignIn,
        ),
        const SizedBox(height: 28),
        const TripSplitSectionLabelDivider(label: 'OR CONTINUE WITH'),
        const SizedBox(height: 24),
        _SocialActions(
          isBusy: isBusy,
          onGoogleTap: onGoogleSignIn,
          onAppleTap: onAppleTap,
        ),
      ],
    );
  }
}

class _SocialActions extends StatelessWidget {
  const _SocialActions({
    required this.isBusy,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  final bool isBusy;
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

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
              child: _SocialButton(
                iconPath: 'assets/icons/google.png',
                label: 'GOOGLE',
                onTap: isBusy ? null : onGoogleTap,
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: _SocialButton(
                iconPath: 'assets/icons/apple.png',
                label: 'APPLE',
                onTap: isBusy ? null : onAppleTap,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.iconPath,
    required this.label,
    this.onTap,
  });

  final String iconPath;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final AuthColorTokens colors = appColors.auth;
    final SharedColorTokens shared = appColors.shared;
    final bool isEnabled = onTap != null;

    return Opacity(
      opacity: isEnabled ? 1 : 0.55,
      child: Material(
        color: shared.cardBackground,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
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
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
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
      ),
    );
  }
}
