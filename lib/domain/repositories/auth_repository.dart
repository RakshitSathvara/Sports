import '../entities/login_entity.dart';

abstract class AuthRepository {
  Future<LoginEntity> login({required String username, required String password, String? notificationToken});
}
