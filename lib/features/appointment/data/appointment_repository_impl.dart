import 'package:oqdo_mobile_app/data/api_client.dart';
import '../domain/appointment_entity.dart';
import '../domain/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final ApiClient apiClient;

  AppointmentRepositoryImpl(this.apiClient);

  @override
  Future<List<AppointmentEntity>> fetchAppointments() async {
    final result = await apiClient.get('/appointments');
    if (result is List) {
      return result
          .map((e) => AppointmentEntity(
                id: e['id'].toString(),
                date: DateTime.parse(e['date']),
              ))
          .toList();
    } else {
      return [];
    }
  }
}
