import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/app_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/local/token_manager.dart';
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/domain/entities/user_data.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<StatefulWidget> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage>
    with AutomaticKeepAliveClientMixin {
  late Future<UserData?> _userFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<UserData?> _loadUser() async {
    final tokenManager = di.getIt<TokenManager>();
    final token = await tokenManager.getToken();
    if (token == null || token.isEmpty) {
      return tokenManager.getCachedUser();
    }

    final response = await di.getIt<ApiService>().getProfile();
    final profile = response.data?.toEntity();
    if (profile != null) {
      final cached = await tokenManager.getCachedUser();
      final merged = UserData(
        accessToken: cached?.accessToken ?? token,
        refreshToken: cached?.refreshToken ?? '',
        userId: profile.userId,
        userName: profile.userName,
        email: profile.email,
        avatarUrl: profile.avatarUrl,
      );
      await tokenManager.saveUser(merged);
      return merged;
    }

    return tokenManager.getCachedUser();
  }

  Future<void> _refresh() async {
    setState(() {
      _userFuture = _loadUser();
    });
  }

  Future<void> _logout() async {
    await di.getIt<TokenManager>().clearToken();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: FutureBuilder<UserData?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null || user.accessToken.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('当前未登录'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await context.push(AppRouter.login);
                      await _refresh();
                    },
                    child: const Text('去登录'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CircleAvatar(
                  radius: 36,
                  child: Text(
                    user.userName.isNotEmpty ? user.userName[0] : 'U',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.userName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('用户 ID'),
                  subtitle: Text(user.userId),
                ),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined),
                  title: const Text('登录态'),
                  subtitle: const Text('已缓存 access token / refresh token'),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('编辑资料'),
                  subtitle: const Text('修改昵称和头像地址'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await context.push(AppRouter.editProfile);
                    await _refresh();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('地址管理'),
                  subtitle: const Text('查看、新增、编辑、删除收货地址'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRouter.addresses),
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('我的订单'),
                  subtitle: const Text('查看订单列表和订单详情'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRouter.orders),
                ),
                ListTile(
                  leading: const Icon(Icons.monitor_heart_outlined),
                  title: const Text('服务状态'),
                  subtitle: const Text('查看 /ping 返回的服务健康信息'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRouter.health),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: _logout,
                  child: const Text('退出登录'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
