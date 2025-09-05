import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../di/injection.dart';
import '../bloc/login/login_bloc.dart';
import '../screens/login_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<LoginBloc>(),
        child: const LoginPage(),
      ),
    ),
  ],
);
