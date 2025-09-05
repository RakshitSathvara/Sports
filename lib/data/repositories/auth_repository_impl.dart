import '../../domain/entities/login_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<LoginEntity> login({required String username, required String password, String? notificationToken}) async {
    final dto = await remote.login(username, password, notificationToken: notificationToken);
    return dto.toEntity();
  }
}
