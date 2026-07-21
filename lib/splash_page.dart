import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'signin_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;
    final SplashColorTokens colors = appColors.splash;
    final SharedColorTokens shared = appColors.shared;
    final mediaQuery = MediaQuery.sizeOf(context);
    final compactHeight = mediaQuery.height < 760;
    final horizontalPadding = mediaQuery.width < 360 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomPaint(
        painter: _BackgroundTexturePainter(textureColor: colors.texture),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  compactHeight ? 48 : 64,
                  horizontalPadding,
                  compactHeight ? 28 : 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        const SizedBox(height: 60),
                        Image.asset(
                          'assets/icons/plane.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'TRIPSPLIT',
                          style: GoogleFonts.plusJakartaSans(
                            color: colors.title,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.33,
                            letterSpacing: 4.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Split trips. Share expenses. Settle fast.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: colors.subtitle,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const SignInPage(),
                            ),
                          );
                        },
                        style:
                            ElevatedButton.styleFrom(
                              backgroundColor: colors.buttonFill,
                              foregroundColor: shared.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: shared.transparent,
                              textStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.14,
                                letterSpacing: 1.65,
                              ),
                            ).copyWith(
                              overlayColor: WidgetStatePropertyAll<Color>(
                                shared.overlayWhite08,
                              ),
                              shadowColor: WidgetStatePropertyAll<Color>(
                                shared.transparent,
                              ),
                            ),
                        child: Ink(
                          decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: colors.buttonFill.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: colors.buttonFill.withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 10),
                                spreadRadius: -3,
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: const Text('GET STARTED'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundTexturePainter extends CustomPainter {
  const _BackgroundTexturePainter({required this.textureColor});

  final Color textureColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = textureColor.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    const spacing = 18.0;

    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
