import 'package:shop/domain/entities/user_data.dart';

class UserModel {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String userName;
  final String email;
  final String avatarUrl;

  const UserModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.userName,
    required this.email,
    required this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user =
        json['user'] is Map<String, dynamic>
            ? json['user'] as Map<String, dynamic>
            : json;

    return UserModel(
      accessToken: (json['access_token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      userId: (user['id'] ?? '').toString(),
      userName: (user['nickname'] ?? user['email'] ?? '').toString(),
      email: (user['email'] ?? '').toString(),
      avatarUrl: (user['avatar_url'] ?? '').toString(),
    );
  }
}

extension UserModelX on UserModel {
  UserData toEntity() => UserData(
    accessToken: accessToken,
    refreshToken: refreshToken,
    userId: userId,
    userName: userName,
    email: email,
    avatarUrl: avatarUrl,
  );
}
