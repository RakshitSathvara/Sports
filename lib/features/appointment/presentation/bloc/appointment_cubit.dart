import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/appointment_repository.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  final AppointmentRepository repository;
  AppointmentCubit(this.repository) : super(AppointmentInitial());

  Future<void> loadAppointments() async {
    emit(AppointmentLoading());
    try {
      final appointments = await repository.fetchAppointments();
      emit(AppointmentLoaded(appointments));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
}
