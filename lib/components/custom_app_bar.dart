import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget> actions;
  final Function() onBack;
  final Color? backgroundColor;
  final bool? isIconColorBlack;
  final bool? isTextColor;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.actions = const [],
      required this.onBack,
      this.backgroundColor,
      this.isIconColorBlack = true,
      this.isTextColor = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
          onPressed: () {
            onBack();
          },
          icon: Icon(
            Icons.arrow_back,
            color: (isIconColorBlack ?? true) ? Colors.black : Colors.white,
          )),
      backgroundColor: backgroundColor ?? Colors.white,
      title: Text(
        title ?? '',
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: (isIconColorBlack ?? true) ? OQDOThemeData.blackColor : Colors.white, fontWeight: FontWeight.w600, fontSize: 20.0),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
