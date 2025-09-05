import 'package:equatable/equatable.dart';
import '../../../domain/entities/login_entity.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginEntity user;
  const LoginSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);
  @override
  List<Object?> get props => [message];
}
