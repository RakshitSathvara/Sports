import 'package:flutter/material.dart';

const styleTitle = 'title';
const styleSubTitle = 'subtitle';
const styleHead = 'head';
const styleHeadBold = 'head_bold';
const styleSubHead = 'subhead';
const styleCaption = 'caption';
const styleCaptionBold = 'caption_bold';
const styleBody1 = 'body1';
const styleBody2 = 'body2';
const styleSubTitleBold = 'subtitle_bold';
const styleTitleBold = 'title_bold';

class CustomTextView extends StatelessWidget {
  final String? type;
  final String? label;
  final TextStyle? textStyle;
  final int? maxLine;
  final TextOverflow? textOverflow;
  final TextAlign? textAlign;
  final Color? color;
  final bool isStrikeThrough;

  const CustomTextView({
    Key? key,
    required this.label,
    this.type,
    this.textStyle,
    this.maxLine = 1,
    this.isStrikeThrough = false,
    this.textOverflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseStyle = textStyle ?? _getTextStyle(context);
    final finalStyle = baseStyle?.copyWith(
      color: color ?? baseStyle.color,
      overflow: textOverflow,
      decoration: isStrikeThrough ? TextDecoration.lineThrough : null,
    );

    return Text(
      label ?? '',
      style: finalStyle,
      maxLines: maxLine,
      textAlign: textAlign,
    );
  }

  TextStyle? _getTextStyle(BuildContext context) {
    switch (type) {
      case styleTitle:
        return Theme.of(context).textTheme.displayMedium;
      case styleSubTitle:
        return Theme.of(context).textTheme.titleMedium;
      case styleHead:
        return Theme.of(context).textTheme.headlineSmall;
      case styleHeadBold:
        return Theme.of(context).textTheme.displaySmall;
      case styleSubHead:
        return Theme.of(context).textTheme.titleLarge;
      case styleCaption:
        return Theme.of(context).textTheme.displayMedium;
      case styleCaptionBold:
        return Theme.of(context).textTheme.bodySmall;
      case styleBody1:
        return Theme.of(context).textTheme.bodySmall;
      case styleBody2:
        return Theme.of(context).textTheme.bodyMedium;
      case styleSubTitleBold:
        return Theme.of(context).textTheme.titleSmall;
      case styleTitleBold:
        return Theme.of(context).textTheme.titleMedium;
      default:
        return Theme.of(context).textTheme.bodyLarge;
    }
  }
}
