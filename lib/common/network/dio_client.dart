import 'package:dio/dio.dart';
import 'package:shop/common/constants/api_constants.dart';

class DioClient {
  late final Dio dio;

  DioClient({
    required List<Interceptor> interceptors,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll(interceptors);
  }
}
