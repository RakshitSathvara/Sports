import 'package:http/http.dart' as http;
import '../models/login_dto.dart';
import '../../utils/constants.dart';

class AuthRemoteDataSource {
  final http.Client client;
  AuthRemoteDataSource(this.client);

  Future<LoginDto> login(String username, String password, {String? notificationToken}) async {
    final response = await client.post(
      Uri.parse('${Constants.BASE_URL}/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'password',
        'Client_id': 'AndroidApp',
        'Client_Secret': Constants.androidSecret,
        'username': username,
        'password': password,
        'NotificationToken': notificationToken ?? '',
      },
    );
    return LoginDto.fromJson(response.body);
  }
}
