import 'package:dio/dio.dart';
import 'package:shop/data/datasources/local/token_manager.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager tokenManager;

  AuthInterceptor(this.tokenManager);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenManager.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
