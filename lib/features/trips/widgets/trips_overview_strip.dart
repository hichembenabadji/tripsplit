import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/formatters.dart';

class TripsOverviewStrip extends StatelessWidget {
  const TripsOverviewStrip({
    required this.activeTripCount,
    required this.totalOutstanding,
    required this.currencyCode,
    required this.youAreOwed,
    required this.youOwe,
    super.key,
  });

  final int activeTripCount;
  final double totalOutstanding;
  final String currencyCode;
  final double youAreOwed;
  final double youOwe;

  static const _borderColor = Color(0xFF564338);
  static const _bodyColor = Color(0xFF564338);
  static const _titleColor = Color(0xFF151B2B);
  static const _panelBackground = Color(0xFFFAF7F2);
  static const _green = Color(0xFF22C268);
  static const _red = Color(0xFFBA1A1A);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _borderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x0C000000),
            blurRadius: 2.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'GLOBAL OVERVIEW',
                      style: GoogleFonts.jetBrainsMono(
                        color: _bodyColor,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        letterSpacing: 1.1.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Active Trips: $activeTripCount',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF404758),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'TOTAL OUTSTANDING',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.jetBrainsMono(
                      color: _bodyColor,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                      letterSpacing: 1.1.sp,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppFormatters.currency(
                        totalOutstanding,
                        currencyCode: currencyCode,
                      ),
                      textAlign: TextAlign.right,
                      style: GoogleFonts.jetBrainsMono(
                        color: _titleColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        letterSpacing: -0.16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          const _TripsDashedDivider(),
          SizedBox(height: 8.h),
          Row(
            children: <Widget>[
              Expanded(
                child: _OverviewAmountCard(
                  label: 'YOU ARE OWED',
                  amount:
                      '+ ${AppFormatters.currency(youAreOwed, currencyCode: currencyCode)}',
                  amountColor: _green,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _OverviewAmountCard(
                  label: 'YOU OWE',
                  amount:
                      '- ${AppFormatters.currency(youOwe, currencyCode: currencyCode)}',
                  amountColor: _red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewAmountCard extends StatelessWidget {
  const _OverviewAmountCard({
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final String label;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: TripsOverviewStrip._panelBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0x4C564338)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: TripsOverviewStrip._bodyColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          SizedBox(height: 4.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: GoogleFonts.jetBrainsMono(
                color: amountColor,
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripsDashedDivider extends StatelessWidget {
  const _TripsDashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 6.w).floor();

        return Row(
          children: List<Widget>.generate(dashCount, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Container(height: 1.h, color: const Color(0xFFA58C7F)),
              ),
            );
          }),
        );
      },
    );
  }
}
