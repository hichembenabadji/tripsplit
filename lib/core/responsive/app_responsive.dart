import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppResponsive {
  static const designSize = Size(390, 844);

  static EdgeInsets get pagePadding => EdgeInsets.all(24.w);

  static EdgeInsets get pageHeaderPadding =>
      EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h);

  static EdgeInsets get pageBottomActionPadding =>
      EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h);
}

extension ResponsiveGap on num {
  SizedBox get gapH => SizedBox(height: h);

  SizedBox get gapW => SizedBox(width: w);
}
