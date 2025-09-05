# Flutter App Architecture

## 📱 Overview

This Flutter application follows a scalable, maintainable architecture using **MVVM pattern** with **BLoC state management**, incorporating security best practices, internationalization support, and robust API integration.

## 🏗️ Architecture Overview

```
lib/
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   ├── api_endpoints.dart
│   │   └── interceptors/
│   ├── constants/
│   ├── errors/
│   ├── security/
│   ├── utils/
│   └── widgets/
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   └── remote/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── blocs/
│   ├── pages/
│   ├── view_models/
│   └── widgets/
├── l10n/
│   ├── app_en.arb
│   └── app_es.arb
└── main.dart
```

## 🎯 Core Components

### 1. MVVM Pattern Implementation

The app follows the **Model-View-ViewModel** pattern with clear separation of concerns:

- **Model**: Data layer (entities, repositories, data sources)
- **View**: Presentation layer (pages, widgets)
- **ViewModel**: Business logic layer (BLoCs, ViewModels)

#### ViewModel Example

```dart
// lib/presentation/view_models/user_view_model.dart
class UserViewModel extends ChangeNotifier {
  final GetUserUseCase _getUserUseCase;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  UserViewModel(this._getUserUseCase);
  
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final result = await _getUserUseCase.execute(userId);
    result.fold(
      (failure) => _error = failure.message,
      (user) => _user = user,
    );
    
    _isLoading = false;
    notifyListeners();
  }
}
```

### 2. BLoC State Management

#### BLoC Setup

```dart
// lib/presentation/blocs/auth/auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  
  AuthBloc({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await _loginUseCase.execute(
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
```

#### BLoC States

```dart
// lib/presentation/blocs/auth/auth_state.dart
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  
  const AuthAuthenticated(this.user);
  
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

### 3. API Integration

#### API Client Configuration

```dart
// lib/core/api/api_client.dart
import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  final SecurityManager _securityManager;
  
  ApiClient({
    required this.baseUrl,
    required SecurityManager securityManager,
  }) : _securityManager = securityManager {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(AuthInterceptor(_securityManager));
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }
  
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }
}
```

#### Auth Interceptor

```dart
// lib/core/api/interceptors/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  final SecurityManager _securityManager;
  
  AuthInterceptor(this._securityManager);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _securityManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _securityManager.refreshToken();
      if (refreshed) {
        // Retry the request
        final opts = err.requestOptions;
        final token = await _securityManager.getAccessToken();
        opts.headers['Authorization'] = 'Bearer $token';
        
        final response = await _dio.request(
          opts.path,
          options: Options(
            method: opts.method,
            headers: opts.headers,
          ),
          data: opts.data,
          queryParameters: opts.queryParameters,
        );
        
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }
}
```

### 4. Security Implementation

#### Security Manager

```dart
// lib/core/security/security_manager.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';

class SecurityManager {
  static const _storage = FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Token Management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }
  
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }
  
  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
  
  // Biometric Authentication
  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;
      
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }
  
  // Data Encryption
  String encryptData(String plainText, String key) {
    final bytes = utf8.encode(plainText);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Certificate Pinning (for production)
  bool validateCertificate(String certificate) {
    // Implement certificate validation logic
    return true;
  }
}
```

#### Security Best Practices

```dart
// lib/core/security/security_config.dart
class SecurityConfig {
  // API Security
  static const bool enableCertificatePinning = true;
  static const List<String> trustedCertificates = [
    // Add your certificate hashes here
  ];
  
  // Data Protection
  static const bool enableDataEncryption = true;
  static const bool enableBiometricAuth = true;
  
  // Session Management
  static const Duration sessionTimeout = Duration(minutes: 15);
  static const Duration refreshTokenExpiry = Duration(days: 30);
  
  // Input Validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  static bool isValidPassword(String password) {
    // At least 8 chars, 1 uppercase, 1 lowercase, 1 number, 1 special char
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }
  
  // Sanitization
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false), '')
        .replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
```

### 5. Internationalization (i18n)

#### Setup

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
  
flutter:
  generate: true
```

#### ARB Files

```json
// lib/l10n/app_en.arb
{
  "@@locale": "en",
  "appTitle": "My Flutter App",
  "welcomeMessage": "Welcome back, {username}!",
  "@welcomeMessage": {
    "description": "Welcome message shown to logged in users",
    "placeholders": {
      "username": {
        "type": "String"
      }
    }
  },
  "login": "Login",
  "logout": "Logout",
  "email": "Email",
  "password": "Password",
  "errorInvalidEmail": "Please enter a valid email",
  "errorPasswordTooShort": "Password must be at least 8 characters",
  "errorNetworkConnection": "Please check your internet connection"
}
```

```json
// lib/l10n/app_es.arb
{
  "@@locale": "es",
  "appTitle": "Mi Aplicación Flutter",
  "welcomeMessage": "¡Bienvenido de nuevo, {username}!",
  "login": "Iniciar sesión",
  "logout": "Cerrar sesión",
  "email": "Correo electrónico",
  "password": "Contraseña",
  "errorInvalidEmail": "Por favor ingrese un correo válido",
  "errorPasswordTooShort": "La contraseña debe tener al menos 8 caracteres",
  "errorNetworkConnection": "Por favor verifique su conexión a internet"
}
```

#### Localization Setup

```dart
// lib/main.dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<LanguageBloc>()),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Flutter App',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: state.locale,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
```

#### Language Management BLoC

```dart
// lib/presentation/blocs/language/language_bloc.dart
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final SharedPreferences _prefs;
  
  LanguageBloc(this._prefs) : super(LanguageState(Locale('en'))) {
    on<ChangeLanguage>(_onChangeLanguage);
    on<LoadSavedLanguage>(_onLoadSavedLanguage);
  }
  
  void _onChangeLanguage(ChangeLanguage event, Emitter<LanguageState> emit) async {
    await _prefs.setString('language_code', event.locale.languageCode);
    emit(LanguageState(event.locale));
  }
  
  void _onLoadSavedLanguage(LoadSavedLanguage event, Emitter<LanguageState> emit) {
    final languageCode = _prefs.getString('language_code') ?? 'en';
    emit(LanguageState(Locale(languageCode)));
  }
}
```

## 📦 Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
    
  # State Management
  flutter_bloc: ^8.1.3
  bloc: ^8.1.2
  equatable: ^2.0.5
  provider: ^6.0.5
  
  # API & Networking
  dio: ^5.3.2
  retrofit: ^4.0.3
  pretty_dio_logger: ^1.3.1
  
  # Security
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.1.6
  crypto: ^3.0.3
  
  # Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2
  
  # Local Storage
  shared_preferences: ^2.2.1
  hive_flutter: ^1.1.0
  
  # Utilities
  intl: ^0.18.0
  dartz: ^0.10.1
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.3
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
  freezed: ^2.4.5
  injectable_generator: ^2.4.1
  retrofit_generator: ^7.0.8
  bloc_test: ^9.1.4
  mocktail: ^1.0.1
```

## 🚀 Getting Started

### 1. Initial Setup

```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Generate localization files
flutter gen-l10n
```

### 2. Dependency Injection Setup

```dart
// lib/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register API Client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(
      baseUrl: Environment.apiBaseUrl,
      securityManager: getIt<SecurityManager>(),
    ),
  );
  
  // Register Security Manager
  getIt.registerLazySingleton<SecurityManager>(() => SecurityManager());
  
  // Register Repositories
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      remoteDataSource: getIt<UserRemoteDataSource>(),
      localDataSource: getIt<UserLocalDataSource>(),
    ),
  );
  
  // Register Use Cases
  getIt.registerFactory(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => GetUserUseCase(getIt<UserRepository>()));
  
  // Register BLoCs
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );
}
```

### 3. Environment Configuration

```dart
// lib/core/constants/environment.dart
class Environment {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
  
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );
  
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
}
```

## 🧪 Testing

### Unit Test Example

```dart
// test/presentation/blocs/auth_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  
  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    authBloc = AuthBloc(loginUseCase: mockLoginUseCase);
  });
  
  tearDown(() {
    authBloc.close();
  });
  
  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });
    
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login is successful',
      build: () {
        when(() => mockLoginUseCase.execute(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(
        LoginRequested(email: 'test@example.com', password: 'password123'),
      ),
      expect: () => [
        AuthLoading(),
        AuthAuthenticated(testUser),
      ],
    );
  });
}
```

## 🔐 Security Checklist

- [ ] Enable certificate pinning for production
- [ ] Implement proper input validation and sanitization
- [ ] Use secure storage for sensitive data
- [ ] Implement session timeout
- [ ] Enable biometric authentication where available
- [ ] Obfuscate code for release builds
- [ ] Implement rate limiting for API calls
- [ ] Use HTTPS for all network communication
- [ ] Implement proper error handling without exposing sensitive info
- [ ] Regular security audits and dependency updates

## 📝 Best Practices

1. **State Management**: Use BLoC for complex business logic and Provider for simple UI state
2. **Code Organization**: Follow clean architecture principles with clear separation between layers
3. **Error Handling**: Implement comprehensive error handling with user-friendly messages
4. **Performance**: Use const constructors, lazy loading, and proper disposal of resources
5. **Testing**: Maintain high test coverage (aim for >80%)
6. **Documentation**: Document complex logic and public APIs
7. **Version Control**: Use semantic versioning and conventional commits

## 🛠️ Build & Deploy

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
flutter build ios --release --obfuscate --split-debug-info=./debug-info
```

### Environment-specific Builds
```bash
flutter run --dart-define=API_BASE_URL=https://api.production.com --dart-define=ENVIRONMENT=production
```

### Deep Linking Configuration

#### Android (android/app/src/main/AndroidManifest.xml)
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="myapp"
    android:host="open" />
</intent-filter>
```

#### iOS (ios/Runner/Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
    <key>CFBundleURLName</key>
    <string>com.example.myapp</string>
  </dict>
</array>
```

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [BLoC Library Documentation](https://bloclibrary.dev)
- [Flutter Security Best Practices](https://flutter.dev/docs/deployment/best-practices)
- [Flutter Internationalization](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
