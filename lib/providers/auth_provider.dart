import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

class AuthProvider with ChangeNotifier {
  final _api = ApiService();
  final _storage = StorageService();

  //status
  AuthStatus _status = AuthStatus.unknown;
  String? _token;
  String? _error;
  bool _isLoading = false;
  String? _userEmail;
  String? _userName;

  //getters
  AuthStatus get status => _status;
  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _isLoading;
  String? get userEmail => _userEmail;
String? get userName  => _userName;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  //check login status on app start
  //called ones when app launches
  Future<void> checkAuthStatus() async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      _token = token;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners(); // notify UI about status change
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  //registers
  Future<void> register({
    required String name,
    required String email,
    required String password,

  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _api.register(email,password);
      await _storage.saveToken(token); // persist token
      _token = token;
      _userEmail = email;  // ← ADD THIS
      _userName  = name; 
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  //login
  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);

    try {
      final token = await _api.login(email, password);
      await _storage.saveToken(token); // persist token
      _token = token;
      _userEmail = email;  // ← ADD THIS
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
     

  //logout
  Future<void> logout() async {
    await _storage.deleteToken(); // remove token from storage
    _token = null;
    _userEmail = null;  // ← ADD THIS
    _userName  = null; 
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
