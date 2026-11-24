import 'package:flutter/foundation.dart';
import '../services/api_exception.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _user = null;
    notifyListeners();

    try {
      await _authService.login(emailOrPhone, password);
      _user = await _authService.getCurrentUser();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String fullName,
    required String emailOrPhone,
    required String password,
    required String passwordConfirmation,
    required String userType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _user = null;
    notifyListeners();

    try {
      await _authService.register(
        fullName: fullName,
        emailOrPhone: emailOrPhone,
        password: password,
        passwordConfirmation: passwordConfirmation,
        userType: userType,
      );
      _user = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getCurrentUser();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCurrentUser() async {
    try {
      if (await _authService.isLoggedIn()) {
        _user = await _authService.getCurrentUser();
        notifyListeners();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }
}
