import 'package:flutter/material.dart';
import 'routes/app_router.dart';

class SportsApp extends StatelessWidget {
  const SportsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Sports',
    );
  }
}
