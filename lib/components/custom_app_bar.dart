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
      this.isIconColorBlack,
      this.isTextColor});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color resolvedIconColor = isIconColorBlack == null
        ? (isDark ? Colors.white : Colors.black)
        : (isIconColorBlack! ? Colors.black : Colors.white);

    final Color resolvedTextColor = (isTextColor == false)
        ? Colors.white
        : resolvedIconColor;

    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      leading: IconButton(
        onPressed: onBack,
        icon: Icon(Icons.arrow_back, color: resolvedIconColor),
      ),
      title: Text(
        title ?? '',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: resolvedTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
            ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
