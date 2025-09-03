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
  String? type;
  String? label;
  TextStyle? textStyle;
  int? maxLine;
  TextOverflow? textOverflow;
  TextAlign? textAlign;
  Color? color;
  bool isStrikeThrough = false;

  CustomTextView({
    Key? key,
    @required this.label,
    this.type,
    this.textStyle,
    this.maxLine = 1,
    this.isStrikeThrough = false,
    TextOverflow? textOverFlow = TextOverflow.ellipsis,
    TextAlign? textAlign = TextAlign.start,
    Color? color = Colors.grey,
  }) : super(key: key) {
    this.textAlign = TextAlign.start;
    textOverflow = TextOverflow.ellipsis;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(text: label, style: textStyle ?? _getTextStyle(context)!.copyWith(color: color, overflow: textOverflow)),
      softWrap: true,
      maxLines: maxLine,
      textAlign: textAlign!,
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
    }
    return Theme.of(context).textTheme.bodyLarge;
  }
}
