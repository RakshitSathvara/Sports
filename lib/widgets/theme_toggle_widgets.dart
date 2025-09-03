import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return IconButton(
          icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: () => themeProvider.toggleTheme(),
        );
      },
    );
  }
}

class ThemeSettingsWidget extends StatelessWidget {
  const ThemeSettingsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            RadioListTile<ThemeType>(
              title: const Text('Light Mode'),
              subtitle: const Text('Use light theme'),
              value: ThemeType.light,
              groupValue: themeProvider.themeType,
              onChanged: (value) =>
                  value != null ? themeProvider.setTheme(value) : null,
            ),
            RadioListTile<ThemeType>(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: ThemeType.dark,
              groupValue: themeProvider.themeType,
              onChanged: (value) =>
                  value != null ? themeProvider.setTheme(value) : null,
            ),
            RadioListTile<ThemeType>(
              title: const Text('System Default'),
              subtitle: const Text('Follow system theme'),
              value: ThemeType.system,
              groupValue: themeProvider.themeType,
              onChanged: (value) =>
                  value != null ? themeProvider.setTheme(value) : null,
            ),
          ],
        );
      },
    );
  }
}
