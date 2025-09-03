import 'dart:io';

void main() async {
  print('🔍 Analyzing Flutter project for theme migration...\n');

  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ lib directory not found. Run this from your Flutter project root.');
    exit(1);
  }

  final analysisResults = <String, int>{
    'ColorsUtils static calls': 0,
    'OQDOThemeData static calls': 0,
    'Colors.white usage': 0,
    'Colors.black usage': 0,
    'Hardcoded color hex': 0,
    'Theme-aware calls': 0,
  };

  final filesToMigrate = <String>[];

  await for (final file in libDir.list(recursive: true)) {
    if (file.path.endsWith('.dart')) {
      final content = await File(file.path).readAsString();

      final colorsUtilsMatches = RegExp(r'ColorsUtils\.\w+').allMatches(content);
      final oqdoThemeMatches = RegExp(r'OQDOThemeData\.\w+').allMatches(content);
      final colorsWhiteMatches = RegExp(r'Colors\.white').allMatches(content);
      final colorsBlackMatches = RegExp(r'Colors\.black').allMatches(content);
      final hexColorMatches = RegExp(r'Color\(0x[0-9A-Fa-f]+\)').allMatches(content);
      final themeAwareMatches = RegExp(r'Theme\.of\(context\)').allMatches(content);

      final totalIssues = colorsUtilsMatches.length +
          oqdoThemeMatches.length +
          colorsWhiteMatches.length +
          colorsBlackMatches.length +
          hexColorMatches.length;

      if (totalIssues > 0) {
        filesToMigrate.add('${file.path}: $totalIssues issues');

        analysisResults['ColorsUtils static calls'] =
            (analysisResults['ColorsUtils static calls'] ?? 0) + colorsUtilsMatches.length;
        analysisResults['OQDOThemeData static calls'] =
            (analysisResults['OQDOThemeData static calls'] ?? 0) + oqdoThemeMatches.length;
        analysisResults['Colors.white usage'] =
            (analysisResults['Colors.white usage'] ?? 0) + colorsWhiteMatches.length;
        analysisResults['Colors.black usage'] =
            (analysisResults['Colors.black usage'] ?? 0) + colorsBlackMatches.length;
        analysisResults['Hardcoded color hex'] =
            (analysisResults['Hardcoded color hex'] ?? 0) + hexColorMatches.length;
      }

      analysisResults['Theme-aware calls'] =
          (analysisResults['Theme-aware calls'] ?? 0) + themeAwareMatches.length;
    }
  }

  print('📊 MIGRATION ANALYSIS RESULTS\n');
  print('=' * 50);

  analysisResults.forEach((key, value) {
    final emoji = key == 'Theme-aware calls' ? '✅' : '⚠️';
    print('$emoji $key: $value');
  });

  print('\n📁 FILES NEEDING MIGRATION (${filesToMigrate.length} total):');
  print('=' * 50);

  filesToMigrate.take(20).forEach(print);
  if (filesToMigrate.length > 20) {
    print('... and ${filesToMigrate.length - 20} more files');
  }

  final totalIssues = analysisResults.values
          .where((value) => value > 0)
          .fold(0, (a, b) => a + b) -
      (analysisResults['Theme-aware calls'] ?? 0);

  print('\n🎯 MIGRATION PRIORITY:');
  print('=' * 50);
  if (totalIssues > 500) {
    print('🔴 HIGH - Consider gradual migration approach');
  } else if (totalIssues > 200) {
    print('🟡 MEDIUM - Can be done in phases');
  } else {
    print('🟢 LOW - Can be migrated quickly');
  }

  print('\n💡 RECOMMENDATIONS:');
  print('=' * 50);
  print('1. Start with ColorsUtils migration (automatic)');
  print('2. Update OQDOThemeData calls (automatic)');
  print('3. Review Colors.white/black usage (manual review needed)');
  print('4. Test each screen after migration');
  print('5. Consider using the provided migration script');
}
