import 'package:flutter/material.dart';
import 'features/appointment/presentation/enduser_appointment_screen.dart';

class AppRouter {
  static const String appointment = '/appointment';

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case appointment:
        return MaterialPageRoute(builder: (_) => EndUserAppointmentScreen());
      default:
        return null;
    }
  }
}
