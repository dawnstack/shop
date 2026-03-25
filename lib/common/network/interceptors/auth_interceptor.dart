import 'package:dio/dio.dart';
import 'package:shop/common/constants/api_constants.dart';
import 'package:shop/data/datasources/local/token_manager.dart';
import 'package:shop/data/models/base_response.dart';
import 'package:shop/data/models/user_model.dart';
import 'package:shop/domain/entities/user_data.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager tokenManager;
  final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<String?>? _refreshingFuture;

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

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;
    final path = requestOptions.path;
    final hasRetried = requestOptions.extra['hasRetried'] == true;

    if (statusCode != 401 ||
        hasRetried ||
        path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh')) {
      handler.next(err);
      return;
    }

    try {
      final refreshedToken = await _refreshAccessToken();
      if (refreshedToken == null || refreshedToken.isEmpty) {
        await tokenManager.clearToken();
        handler.next(err);
        return;
      }

      requestOptions.headers['Authorization'] = 'Bearer $refreshedToken';
      requestOptions.extra['hasRetried'] = true;
      final response = await _refreshDio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } catch (_) {
      await tokenManager.clearToken();
      handler.next(err);
    }
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshingFuture != null) {
      return _refreshingFuture;
    }

    final future = _performRefresh();
    _refreshingFuture = future;
    try {
      return await future;
    } finally {
      _refreshingFuture = null;
    }
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await tokenManager.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final response = await _refreshDio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    final parsed = BaseResponse.fromJson(
      _asMap(response.data),
      (json) => UserModel.fromJson(_asMap(json)),
    );
    final model = parsed.data;
    if (parsed.code != 0 || model == null) {
      return null;
    }

    final cachedUser = await tokenManager.getCachedUser();
    final mergedUser = model.toEntity();
    await tokenManager.updateSession(
      accessToken: mergedUser.accessToken,
      refreshToken: mergedUser.refreshToken,
      user: UserData(
        accessToken: mergedUser.accessToken,
        refreshToken: mergedUser.refreshToken,
        userId: mergedUser.userId.isNotEmpty
            ? mergedUser.userId
            : (cachedUser?.userId ?? ''),
        userName: mergedUser.userName.isNotEmpty
            ? mergedUser.userName
            : (cachedUser?.userName ?? ''),
        email: mergedUser.email.isNotEmpty
            ? mergedUser.email
            : (cachedUser?.email ?? ''),
        avatarUrl: mergedUser.avatarUrl.isNotEmpty
            ? mergedUser.avatarUrl
            : (cachedUser?.avatarUrl ?? ''),
      ),
    );
    return mergedUser.accessToken;
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }
}
