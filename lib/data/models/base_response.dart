class BaseResponse<T> {
  final int code;
  final String msg;
  final T? data;

  const BaseResponse({required this.code, required this.msg, this.data});

  bool get isSuccess => code == 0;
  bool get isFailed => !isSuccess;

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return BaseResponse(
      code: (json['code'] as num?)?.toInt() ?? -1,
      msg: (json['msg'] ?? json['message'] ?? '').toString(),
      data: json['data'] == null ? null : fromJsonT(json['data']),
    );
  }
}
