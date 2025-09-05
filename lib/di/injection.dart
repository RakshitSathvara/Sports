import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../data/datasources/auth_remote_data_source.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../presentation/bloc/login/login_bloc.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSource(getIt()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));
  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt()));
}
