import 'dart:convert';

import 'package:shop/data/datasources/local/local_storage.dart';
import 'package:shop/domain/entities/user_data.dart';

class TokenManager {
  static const String _tokenKey = 'user_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'cached_user';

  final LocalStorage _storage;

  // 这里的核心：通过构造函数注入 LocalStorage
  TokenManager(this._storage);

  /// 保存 Token 和用户信息
  Future<bool> saveToken(String token) async {
    return await _storage.setString(_tokenKey, token);
  }

  Future<bool> saveRefreshToken(String token) async {
    return await _storage.setString(_refreshTokenKey, token);
  }

  Future<bool> saveUser(UserData user) async {
    return await _storage.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<void> saveSession(UserData user) async {
    await saveToken(user.accessToken);
    await saveRefreshToken(user.refreshToken);
    await saveUser(user);
  }

  /// 获取 Token
  Future<String?> getToken() async {
    return _storage.getString(_tokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.getString(_refreshTokenKey);
  }

  Future<UserData?> getCachedUser() async {
    final value = _storage.getString(_userKey);
    if (value == null || value.isEmpty) {
      return null;
    }

    final json = jsonDecode(value);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    return UserData.fromJson(json);
  }

  /// 清除 Token 和用户信息
  Future<void> clearToken() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_refreshTokenKey);
    await _storage.remove(_userKey);
  }

  /// 检查是否已登录
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
