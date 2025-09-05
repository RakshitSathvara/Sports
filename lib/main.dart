import 'package:flutter/material.dart';
import 'di/injection.dart';
import 'presentation/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(const SportsApp());
}
