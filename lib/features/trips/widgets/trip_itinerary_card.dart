import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/trip.dart';
import '../../../data/models/user.dart';

class TripItineraryCard extends StatelessWidget {
  const TripItineraryCard({
    required this.trip,
    required this.members,
    required this.currentUserId,
    required this.onTap,
    super.key,
  });

  final Trip trip;
  final List<User> members;
  final String currentUserId;
  final VoidCallback onTap;

  static const _screenBackground = Color(0xFFFDFAF6);
  static const _cardBorder = Color(0xFF564338);
  static const _cardSurface = Colors.white;
  static const _footerSurface = Color(0xFFFAF7F2);
  static const _titleColor = Color(0xFF151B2B);
  static const _bodyColor = Color(0xFF564338);
  static const _mutedBorder = Color(0xFFA58C7F);
  static const _memberFill = Color(0xFFE8E4DE);
  static const _activeFill = Color(0xFFFF8A3D);
  static const _activeText = Color(0xFF682D00);
  static const _upcomingFill = Color(0xFFE8E4DE);
  static const _upcomingText = Color(0xFF564338);
  static const _settledFill = Color(0xFF22C268);
  static const _settledText = Color(0xFF004922);

  @override
  Widget build(BuildContext context) {
    final badge = _badgeSpecForTrip(trip);
    final visibleMembers = members
        .where((member) => member.id != currentUserId)
        .take(3)
        .toList();
    final showMeBadge = members.any((member) => member.id == currentUserId);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: _cardSurface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _cardBorder),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0x0C000000),
                blurRadius: 2.r,
                offset: Offset(0, 1.h),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            trip.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.geist(
                              color: _titleColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        _StatusTag(spec: badge),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14.sp,
                          color: _bodyColor,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            AppFormatters.dateRange(
                              trip.startDate,
                              trip.endDate,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: _bodyColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: <Widget>[
                        for (final member in visibleMembers) ...<Widget>[
                          _MemberBadge(
                            label: member.name.substring(0, 1).toUpperCase(),
                          ),
                          SizedBox(width: 4.w),
                        ],
                        if (showMeBadge)
                          const _MemberBadge(label: 'ME', isMe: true),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  const _DashedDivider(color: _mutedBorder),
                  Positioned(
                    left: -8.w,
                    top: -8.h,
                    child: const _TicketNotch(),
                  ),
                  Positioned(
                    right: -8.w,
                    top: -8.h,
                    child: const _TicketNotch(),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: _footerSurface,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'TOTAL',
                      style: GoogleFonts.jetBrainsMono(
                        color: _bodyColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppFormatters.currency(
                          trip.totalAmount,
                          currencyCode: trip.currencyCode,
                        ),
                        style: GoogleFonts.jetBrainsMono(
                          color: _titleColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusBadgeSpec _badgeSpecForTrip(Trip trip) {
    if (trip.isSettled) {
      return const _StatusBadgeSpec(
        label: 'SETTLED',
        background: _settledFill,
        foreground: _settledText,
      );
    }

    if (trip.id == 'trip-kyoto') {
      return const _StatusBadgeSpec(
        label: 'UPCOMING',
        background: _upcomingFill,
        foreground: _upcomingText,
      );
    }

    return const _StatusBadgeSpec(
      label: 'IN PROGRESS',
      background: _activeFill,
      foreground: _activeText,
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.spec});

  final _StatusBadgeSpec spec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: spec.background,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        spec.label,
        style: GoogleFonts.jetBrainsMono(
          color: spec.foreground,
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
      ),
    );
  }
}

class _MemberBadge extends StatelessWidget {
  const _MemberBadge({required this.label, this.isMe = false});

  final String label;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final background = isMe
        ? TripItineraryCard._activeFill
        : TripItineraryCard._memberFill;
    final foreground = isMe
        ? TripItineraryCard._activeText
        : TripItineraryCard._titleColor;

    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.jetBrainsMono(
            color: foreground,
            fontSize: label.length > 1 ? 10.sp : 11.sp,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});

  final Color color;

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
                child: Container(height: 1.h, color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class _TicketNotch extends StatelessWidget {
  const _TicketNotch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: const BoxDecoration(
        color: TripItineraryCard._screenBackground,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatusBadgeSpec {
  const _StatusBadgeSpec({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}
