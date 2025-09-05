import '../entities/login_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<LoginEntity> call(String username, String password, {String? notificationToken}) {
    return repository.login(username: username, password: password, notificationToken: notificationToken);
  }
}
