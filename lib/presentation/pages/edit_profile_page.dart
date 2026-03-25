import 'package:flutter/material.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/data/datasources/local/token_manager.dart';
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/domain/entities/user_data.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _avatarController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _avatarController = TextEditingController();
    _loadInitialValue();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialValue() async {
    final tokenManager = di.getIt<TokenManager>();
    final cached = await tokenManager.getCachedUser();
    if (cached != null && mounted) {
      _nicknameController.text = cached.userName;
      _avatarController.text = cached.avatarUrl;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) {
      return;
    }

    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final api = di.getIt<ApiService>();
      final tokenManager = di.getIt<TokenManager>();
      final result = await api.updateProfile(
        nickname: _nicknameController.text.trim(),
        avatarUrl: _avatarController.text.trim(),
      );
      if (result.code != 0) {
        messenger.showSnackBar(SnackBar(content: Text(result.msg)));
        return;
      }

      final profile = await api.getProfile();
      final profileUser = profile.data?.toEntity();
      if (profileUser != null) {
        final cached = await tokenManager.getCachedUser();
        await tokenManager.saveUser(
          UserData(
            accessToken: cached?.accessToken ?? '',
            refreshToken: cached?.refreshToken ?? '',
            userId: profileUser.userId,
            userName: profileUser.userName,
            email: profileUser.email,
            avatarUrl: profileUser.avatarUrl,
          ),
        );
      }

      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('资料已更新')));
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑资料')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nicknameController,
              decoration: const InputDecoration(labelText: '昵称'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入昵称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _avatarController,
              decoration: const InputDecoration(labelText: '头像 URL'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? '保存中...' : '保存资料'),
            ),
          ],
        ),
      ),
    );
  }
}
