// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:oqdo_mobile_app/theme/oqdo_theme_data.dart';
import 'package:photo_view/photo_view.dart';

class ViewImageScreen extends StatelessWidget {
  ViewImageScreen({
    super.key,
    this.url,
  });

  String? url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: OQDOThemeData.backgroundColor,
      ),
      body: Center(
        child: PhotoView(
          backgroundDecoration: const BoxDecoration(color: OQDOThemeData.backgroundColor),
          basePosition: Alignment.center,
          imageProvider: NetworkImage(url!),
        ),
      ),
    );
  }
}
