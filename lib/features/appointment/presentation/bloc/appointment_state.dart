import 'package:equatable/equatable.dart';
import '../../domain/appointment_entity.dart';

abstract class AppointmentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<AppointmentEntity> appointments;
  AppointmentLoaded(this.appointments);
  @override
  List<Object?> get props => [appointments];
}

class AppointmentError extends AppointmentState {
  final String message;
  AppointmentError(this.message);
  @override
  List<Object?> get props => [message];
}
