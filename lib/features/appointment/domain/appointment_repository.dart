import 'appointment_entity.dart';

abstract class AppointmentRepository {
  Future<List<AppointmentEntity>> fetchAppointments();
}
