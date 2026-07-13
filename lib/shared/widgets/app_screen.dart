import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/responsive/app_responsive.dart';
import '../../core/theme/app_spacing.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.actions = const <Widget>[],
    this.bottomAction,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final Widget? bottomAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Padding(
            padding: AppResponsive.pageHeaderPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (subtitle != null) ...<Widget>[
                        SizedBox(height: AppSpacing.sm.h),
                        Text(
                          subtitle!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: padding ?? AppResponsive.pagePadding,
              child: child,
            ),
          ),
          if (bottomAction != null)
            Padding(
              padding: AppResponsive.pageBottomActionPadding,
              child: bottomAction!,
            ),
        ],
      ),
    );
  }
}
