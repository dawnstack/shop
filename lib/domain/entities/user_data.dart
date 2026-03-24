class UserData {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String userName;
  final String email;
  final String avatarUrl;

  const UserData({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.userName,
    required this.email,
    this.avatarUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user_id': userId,
      'user_name': userName,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      accessToken: (json['access_token'] ?? '').toString(),
      refreshToken: (json['refresh_token'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      userName: (json['user_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] ?? '').toString(),
    );
  }
}
