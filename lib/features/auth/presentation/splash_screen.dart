import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[AppColors.creamStrong, AppColors.cream],
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _SoftDiagonalPatternPainter()),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 390.w),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 24.h,
                    ),
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Center(
                            child: _WelcomeHero(textTheme: textTheme),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 18.r,
                                offset: Offset(0, 8.h),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => context.go(AppRoutes.signIn),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 48.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              'GET STARTED',
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.white,
                                fontSize: 14.sp,
                                letterSpacing: 1.6.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 18.h),
                        TextButton(
                          onPressed: () => context.go(AppRoutes.signIn),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.mutedInk,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                          ),
                          child: Text(
                            'I already have an account',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF5F4A3D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Opacity(
                          opacity: 0.4,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Image.asset(
                                  'assets/icons/lock.png',
                                  width: 12.w,
                                  height: 12.w,
                                  color: AppColors.ink,
                                  colorBlendMode: BlendMode.srcIn,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'PRIVATE, SECURE AND BUILT FOR GROUPS.',
                                  style: textTheme.labelMedium?.copyWith(
                                    color: AppColors.ink,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.9.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
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
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          'assets/icons/plane.png',
          width: 56.w,
          height: 56.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 18.h),
        Text(
          AppConstants.appName.toUpperCase(),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.ink,
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 4.6.sp,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Split trips. Share expenses. Settle fast.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.mutedInk,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _SoftDiagonalPatternPainter extends CustomPainter {
  const _SoftDiagonalPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.018)
      ..strokeWidth = 1;

    const spacing = 20.0;
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
