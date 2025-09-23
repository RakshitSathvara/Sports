import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onTap: () {
            themeProvider.toggleTheme();
          },
          child: Image.asset(themeProvider.isDarkMode ? 'assets/images/ic_dark.png' : 'assets/images/ic_light.png', width: 30, height: 30),
        );
      },
    );
  }
}
