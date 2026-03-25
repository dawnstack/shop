import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:shop/app_router.dart';
import 'package:shop/presentation/bloc/login/login_bloc.dart';
import 'package:shop/presentation/bloc/login/login_event.dart';
import 'package:shop/presentation/bloc/login/login_state.dart';
import 'package:shop/presentation/widgets/forms/forms.dart';

var _log = Logger('register');

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            context.go(AppRouter.home);
          }

          if (state is LoginFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is LoginLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '创建你的账号',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _nicknameWidget(),
                _emailWidget(),
                _passwordWidget(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
                      child: const Text(
                        '注册',
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('已有账号？返回登录'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onRegisterPressed() {
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    context.read<LoginBloc>().add(
      LoginEvent.registerPressed(
        username: email,
        password: password,
        nickname: nickname.isEmpty ? null : nickname,
      ),
    );
    _log.info('register $email');
  }

  Widget _nicknameWidget() {
    return InputWidget(
      controller: _nicknameController,
      labelText: '昵称（可选）',
      inputType: TextInputType.name,
      maxLength: 32,
      config: const InputConfig(),
    );
  }

  Widget _emailWidget() {
    return InputWidget(
      controller: _emailController,
      labelText: '邮箱',
      inputType: TextInputType.emailAddress,
      maxLength: 64,
      config: const InputConfig(),
    );
  }

  Widget _passwordWidget() {
    return InputWidget(
      controller: _passwordController,
      labelText: '密码',
      inputType: TextInputType.visiblePassword,
      maxLength: 32,
      config: const InputConfig(),
    );
  }
}
