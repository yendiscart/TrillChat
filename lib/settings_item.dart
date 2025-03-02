import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

/// SettingItemWidget
class SettingItemWidget extends StatelessWidget {
  final String title;
  final double? width;
  final String? subTitle;
  final Widget? leading;
  final Widget? trailing;
  final TextStyle? titleTextStyle;
  final TextStyle? subTitleTextStyle;
  final Function? onTap;
  final EdgeInsets? padding;
  final int paddingAfterLeading;
  final int paddingBeforeTrailing;
  final Color? titleTextColor;
  final Color? subTitleTextColor;
  final Color? hoverColor;
  final Color? splashColor;
  final Decoration? decoration;
  final double? borderRadius;
  final BorderRadius? radius;

  SettingItemWidget({
    required this.title,
    this.onTap,
    this.width,
    this.subTitle = '',
    this.leading,
    this.trailing,
    this.titleTextStyle,
    this.subTitleTextStyle,
    this.padding,
    this.paddingAfterLeading = 16,
    this.paddingBeforeTrailing = 16,
    this.titleTextColor,
    this.subTitleTextColor,
    this.decoration,
    this.borderRadius,
    this.hoverColor,
    this.splashColor,
    this.radius,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: decoration ?? BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          leading ?? SizedBox(),
          if (leading != null) 5.height,
          Expanded(
            child: Text(
              title.validate(),
              style: TextStyle(
                fontSize: 12,
                color: titleTextColor
              ),
              maxLines: 1,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
          4.height.visible(subTitle.validate().isNotEmpty),
          if (subTitle.validate().isNotEmpty)
            Text(
              subTitle!,
              style: TextStyle(
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    ).onTap(
      onTap,
      borderRadius: radius ?? (BorderRadius.circular(borderRadius.validate())),
      hoverColor: hoverColor,
      splashColor: splashColor,
    );
  }
}
