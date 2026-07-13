import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/navigation/app_routes.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static const _screenBackground = Color(0xFFFDFCF9);
  static const _brandColor = Color(0xFF9A4600);
  static const _bodyColor = Color(0xFF53433C);
  static const _hintColor = Color(0xFFB8ACA5);
  static const _fieldTextColor = Color(0xCC85736B);
  static const _surfaceTint = Color(0xFFF7F3F0);
  static const _outlineSoft = Color(0x66D8C2B9);
  static const _outlineStrong = Color(0x7FD8C2B9);
  static const _buttonOrange = Color(0xFFFF8A3D);
  static const _buttonOrangeShadow = Color(0x33FF8A3D);
  static const _footerText = Color(0x9953433C);
  static const _footerLink = Color(0xFF85736B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBackground,
      body: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Opacity(
              opacity: 0.4,
              child: Container(
                height: 4.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      Color(0x4C9A4600),
                      Color(0x4CFF8A3D),
                      Color(0x4C9A4600),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                const _SignInHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 56.h, 16.w, 40.h),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 448.w),
                        child: Column(
                          children: <Widget>[
                            const _SignInCard(),
                            SizedBox(height: 32.h),
                            const _PrivacyFooter(),
                          ],
                        ),
                      ),
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

class _SignInHeader extends StatelessWidget {
  const _SignInHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        color: SignInScreen._screenBackground,
        border: Border(bottom: BorderSide(color: Color(0x4CD8C2B9))),
      ),
      child: Row(
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(999.r),
            onTap: () => context.go(AppRoutes.splash),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 14.h),
              child: Image.asset(
                'assets/icons/arrow_left.png',
                width: 20.w,
                height: 20.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'TRIPSPLIT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.geist(
                      color: SignInScreen._brandColor,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: -0.6.sp,
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -2.h),
                    child: Text(
                      'BOARDING ACCESS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        color: SignInScreen._bodyColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        letterSpacing: 1.1.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 36.w),
        ],
      ),
    );
  }
}

class _SignInCard extends StatefulWidget {
  const _SignInCard();

  @override
  State<_SignInCard> createState() => _SignInCardState();
}

class _SignInCardState extends State<_SignInCard> {
  late final TextEditingController _emailController;
  late final TextEditingController _accessCodeController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _accessCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: SignInScreen._outlineStrong),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 30.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 20.w, 24.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Welcome aboard',
                          style: GoogleFonts.geist(
                            color: const Color(0xFF1A1C1A),
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Sign in to manage trips, expenses\nand settlements.',
                        style: GoogleFonts.inter(
                          color: SignInScreen._bodyColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0x19FF8A3D),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0x33FF8A3D)),
                  ),
                  child: Image.asset(
                    'assets/icons/plane.png',
                    width: 18.w,
                    height: 18.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 1.h,
            color: SignInScreen._outlineSoft,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _MonoLabel('PASSENGER EMAIL'),
                SizedBox(height: 4.h),
                _AuthTextField(
                  controller: _emailController,
                  hintText: 'name@airline.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  suffix: Image.asset(
                    'assets/icons/message.png',
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: <Widget>[
                    const Expanded(child: _MonoLabel('ACCESS CODE')),
                    GestureDetector(
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'Forgot password?',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xCC9A4600),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                _AuthTextField(
                  controller: _accessCodeController,
                  hintText: '........',
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  suffix: Image.asset(
                    'assets/icons/key.png',
                    width: 20.w,
                    height: 20.w,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 20.h),
                _PrimarySignInButton(
                  onPressed: () => context.go(AppRoutes.trips),
                ),
                SizedBox(height: 32.h),
                const _SectionDividerLabel(label: 'OR CONTINUE WITH'),
                SizedBox(height: 24.h),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _SocialButton(
                        assetPath: 'assets/icons/google.png',
                        label: 'GOOGLE',
                        onTap: () => context.go(AppRoutes.trips),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _SocialButton(
                        assetPath: 'assets/icons/apple.png',
                        label: 'APPLE',
                        onTap: () => context.go(AppRoutes.trips),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0x33D8C2B9))),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'New to TripSplit?',
                    style: GoogleFonts.inter(
                      color: SignInScreen._bodyColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  _PlainTextButton(
                    label: 'Create account',
                    color: SignInScreen._brandColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1.sp,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimarySignInButton extends StatelessWidget {
  const _PrimarySignInButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: SignInScreen._buttonOrangeShadow,
            blurRadius: 15.r,
            offset: Offset(0, 10.h),
            spreadRadius: -3.r,
          ),
          BoxShadow(
            color: SignInScreen._buttonOrangeShadow,
            blurRadius: 6.r,
            offset: Offset(0, 4.h),
            spreadRadius: -4.r,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SignInScreen._buttonOrange,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 52.h),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Sign In',
              style: GoogleFonts.geist(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            SizedBox(width: 8.w),
            Image.asset(
              'assets/icons/sign_in_arrow.png',
              width: 18.w,
              height: 18.w,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hintText,
    required this.suffix,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
  });

  final TextEditingController controller;
  final String hintText;
  final Widget suffix;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enableSuggestions;
  final bool autocorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 13.4.h),
      decoration: BoxDecoration(
        color: SignInScreen._surfaceTint,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: SignInScreen._outlineSoft),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText,
              autocorrect: autocorrect,
              enableSuggestions: enableSuggestions,
              cursorColor: SignInScreen._brandColor,
              style: GoogleFonts.jetBrainsMono(
                color: SignInScreen._fieldTextColor,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                height: 1.45,
                letterSpacing: 1.1.sp,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: hintText,
                hintStyle: GoogleFonts.jetBrainsMono(
                  color: hintText == 'name@airline.com'
                      ? SignInScreen._hintColor
                      : SignInScreen._fieldTextColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                  letterSpacing: hintText == 'name@airline.com' ? 0 : 1.1.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          suffix,
        ],
      ),
    );
  }
}

class _SectionDividerLabel extends StatelessWidget {
  const _SectionDividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(height: 1.h, color: const Color(0x4CD8C2B9)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0x9953433C),
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1.h, color: const Color(0x4CD8C2B9)),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  final String assetPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: SignInScreen._outlineSoft),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x0C000000),
                blurRadius: 2.r,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                assetPath,
                width: 20.w,
                height: 20.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF1A1C1A),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                  letterSpacing: 1.1.sp,
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
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/icons/lock.png',
                width: 12.w,
                height: 12.w,
                color: SignInScreen._footerText,
                colorBlendMode: BlendMode.srcIn,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 8.w),
              Text(
                'YOUR TRIP DATA STAYS PRIVATE AND ENCRYPTED.',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(
                  color: SignInScreen._footerText,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: 1.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _PlainTextButton(
                label: 'PRIVACY POLICY',
                color: SignInScreen._footerLink,
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                onPressed: () {},
              ),
              SizedBox(width: 32.w),
              _PlainTextButton(
                label: 'TERMS OF SERVICE',
                color: SignInScreen._footerLink,
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlainTextButton extends StatelessWidget {
  const _PlainTextButton({
    required this.label,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
    required this.onPressed,
    this.letterSpacing,
  });

  final String label;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onPressed;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.jetBrainsMono(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.5,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}

class _MonoLabel extends StatelessWidget {
  const _MonoLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.jetBrainsMono(
        color: SignInScreen._brandColor,
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        height: 1.45,
        letterSpacing: 1.1.sp,
      ),
    );
  }
}
