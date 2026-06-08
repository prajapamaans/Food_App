import 'package:dio/dio.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://reqres.in',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Mock register — accepts any email/password
  Future<String> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.length < 6) {
      throw Exception('Invalid credentials.');
    }
    return 'mock_token_${email.hashCode}';
  }

  // Mock login — accepts any email/password
  Future<String> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.length < 6) {
      throw Exception('Invalid credentials.');
    }
    return 'mock_token_${email.hashCode}';
  }

  // Real API — fetch restaurants from reqres
  Future<List<dynamic>> fetchRestaurants(int page) async {
    try {
      final response = await _dio.get(
        '/api/users',
        queryParameters: {'page': page},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return 'No internet connection.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 400) return 'Invalid credentials.';
        if (status == 401) return 'Unauthorized.';
        return 'Request failed ($status).';
      default:
        return 'Something went wrong.';
    }
  }
}