import 'data/api_client.dart';
import 'features/appointment/data/appointment_repository_impl.dart';
import 'features/appointment/domain/appointment_repository.dart';
import 'features/appointment/presentation/bloc/appointment_cubit.dart';

class DIContainer {
  static final DIContainer _instance = DIContainer._internal();
  factory DIContainer() => _instance;
  DIContainer._internal();

  late final AppointmentRepository appointmentRepository;
  late final AppointmentCubit appointmentCubit;

  void init() {
    final apiClient = ApiClient();
    appointmentRepository = AppointmentRepositoryImpl(apiClient);
    appointmentCubit = AppointmentCubit(appointmentRepository);
  }
}
