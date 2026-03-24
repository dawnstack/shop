import 'package:dio/dio.dart';
import 'package:shop/domain/entities/data_result.dart';
import '../models/base_response.dart';

mixin RepositoryHelper {
  Future<DataResult<E>> mapToResult<M, E>({
    required Future<BaseResponse<M>> Function() call,
    required E Function(M model) mapToEntity,
  }) async {
    try {
      // 1. 发起请求
      final response = await call();

      // 如果走到这里，说明 JSON 解析成功
      if (response.code == 0) {
        final data = response.data;
        return data != null
            ? Success(mapToEntity(data))
            : const Failure("数据为空");
      }
      return Failure(response.msg, code: response.code);
    } on DioException catch (e) {
      // ✅ 关键：处理类似 {"msg": "Invalid request"} 的非标准错误
      String errorMessage = _handleDioError(e);

      if (e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          // 兼容后端的各种命名：msg, message, error...
          errorMessage =
              data['msg'] ?? data['message'] ?? data['error'] ?? errorMessage;
        }
      }
      return Failure(errorMessage, code: e.response?.statusCode);
    } catch (e) {
      return Failure("解析异常: $e");
    }
  }

  String _handleDioError(DioException error) {
    // 根据 DioExceptionType 返回用户看得懂的文字
    return switch (error.type) {
      DioExceptionType.connectionTimeout => "网络连接超时",
      DioExceptionType.sendTimeout => "请求超时",
      DioExceptionType.receiveTimeout => "响应超时",
      DioExceptionType.badResponse => "服务器响应异常(${error.response?.statusCode})",
      DioExceptionType.cancel => "请求已取消",
      _ => "网络连接异常，请检查网络",
    };
  }
}
