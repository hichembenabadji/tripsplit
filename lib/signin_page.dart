import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_screen.dart';

void _handleSuccessfulSignIn(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();

  assert(() {
    debugPrint('Sign in pressed: navigating to DashboardScreen');
    return true;
  }());

  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const DashboardScreen(),
    ),
    (Route<dynamic> route) => false,
  );
}

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const _SignInHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                children: <Widget>[
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: const _AuthCard(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: const _PrivacyFooter(),
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

class _SignInHeader extends StatelessWidget {
  const _SignInHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFFFDFCF9),
        border: Border(bottom: BorderSide(color: Color(0x4CD8C2B9))),
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
                    color: const Color(0xFF9A4600),
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

class _AuthCard extends StatelessWidget {
  const _AuthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x7FD8C2B9)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A000000),
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
            padding: const EdgeInsets.only(left: 24, top: 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Welcome',
                  style: GoogleFonts.geist(
                    color: const Color(0xFF1A1C1A),
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in to manage trips, expenses\nand settlements.',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF53433C),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Divider(color: Color(0x4CD8C2B9), thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: ListBody(
              children: const <Widget>[
                _LabeledTextField(
                  label: 'EMAIL',
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: <String>[AutofillHints.email],
                  hintText: 'name@trip.com',
                ),
                SizedBox(height: 24),
                _LabeledTextField(
                  label: 'PASSWORD',
                  hintText: '********',
                  obscureText: true,
                  trailingLabel: 'Forgot password?',
                ),
                SizedBox(height: 20),
                _PrimaryActionButton(),
                SizedBox(height: 28),
                _SectionLabelDivider(label: 'OR CONTINUE WITH'),
                SizedBox(height: 24),
                _SocialActions(),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF7F3F0),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(top: BorderSide(color: Color(0x33D8C2B9))),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: <Widget>[
                Text(
                  'New to TripSplit?',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF53433C),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: const Color(0xFF9A4600),
                  ),
                  child: Text(
                    'Create account',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF9A4600),
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
        ],
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.hintText,
    this.trailingLabel,
    this.keyboardType,
    this.autofillHints,
    this.obscureText = false,
  });

  final String label;
  final String? trailingLabel;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final String hintText;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF9A4600),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            if (trailingLabel != null)
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: const Color(0xFF9A4600),
                ),
                child: Text(
                  trailingLabel!,
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF9A4600),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x99D8C2B9)),
          ),
          child: TextField(
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            obscureText: obscureText,
            obscuringCharacter: '*',
            cursorColor: const Color(0xFF9A4600),
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF53433C),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: GoogleFonts.jetBrainsMono(
                color: const Color(0x9953433C),
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
          ),
        ),
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
              child: _SocialButton(
                iconPath: 'assets/icons/google.png',
                label: 'GOOGLE',
              ),
            ),
            SizedBox(
              width: buttonWidth,
              child: _SocialButton(
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

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        key: const ValueKey<String>('sign_in_button'),
        onPressed: () => _handleSuccessfulSignIn(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF8A3D),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadowColor: Colors.transparent,
          textStyle: GoogleFonts.geist(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 10,
                offset: Offset(0, 8),
                spreadRadius: -6,
              ),
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 25,
                offset: Offset(0, 20),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text('Sign In'),
          ),
        ),
      ),
    );
  }
}

class _SectionLabelDivider extends StatelessWidget {
  const _SectionLabelDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: Color(0x4CD8C2B9), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0x9953433C),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0x4CD8C2B9), thickness: 1)),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.iconPath, required this.label});

  final String iconPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {},
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0x66D8C2B9)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0C000000),
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
                  color: const Color(0xFF1A1C1A),
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

class _PrivacyFooter extends StatelessWidget {
  const _PrivacyFooter();

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0x9953433C),
              colorBlendMode: BlendMode.srcIn,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'YOUR TRIP DATA STAYS PRIVATE AND ENCRYPTED.',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0x9953433C),
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
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: const Color(0xFF85736B),
              ),
              child: Text(
                'PRIVACY POLICY',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF85736B),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: const Color(0xFF85736B),
              ),
              child: Text(
                'TERMS OF SERVICE',
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF85736B),
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
