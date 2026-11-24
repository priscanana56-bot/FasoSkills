import '../config/api_config.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api;

  AuthService({ApiService? api}) : _api = api ?? ApiService();

  Future<Map<String, String>> login(
    String emailOrPhone,
    String password,
  ) async {
    final data =
        await _api.post(
              ApiConfig.loginUrl,
              body: {'email_or_phone': emailOrPhone, 'password': password},
              auth: false,
            )
            as Map<String, dynamic>;

    await _api.saveTokens(data['access'] as String, data['refresh'] as String);
    return {
      'access': data['access'] as String,
      'refresh': data['refresh'] as String,
    };
  }

  Future<void> register({
    required String fullName,
    required String emailOrPhone,
    required String password,
    required String passwordConfirmation,
    required String userType,
  }) async {
    await _api.post(
      ApiConfig.registerUrl,
      body: {
        'full_name': fullName,
        'email_or_phone': emailOrPhone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'user_type': userType,
      },
      auth: false,
    );
  }

  Future<User> getCurrentUser() async {
    final data = await _api.get(ApiConfig.meUrl) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  Future<void> logout() async {
    await _api.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    return _api.hasToken();
  }
}
