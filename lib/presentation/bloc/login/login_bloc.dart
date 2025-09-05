import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase useCase;
  LoginBloc(this.useCase) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLogin);
  }

  Future<void> _onLogin(LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      final user = await useCase(event.username, event.password);
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
