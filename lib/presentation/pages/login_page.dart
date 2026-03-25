import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:shop/app_router.dart';
import 'package:shop/presentation/bloc/login/login_bloc.dart';
import 'package:shop/presentation/bloc/login/login_event.dart';
import 'package:shop/presentation/bloc/login/login_state.dart';
import 'package:shop/presentation/widgets/forms/forms.dart';

var _log = Logger("login");

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: BlocConsumer<LoginBloc, LoginState>(
        builder: (context, state) {
          if (state is LoginLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LoginSuccess) {
            return const Center(
              child: Icon(Icons.check_circle, size: 100, color: Colors.green),
            );
          }

          return _buildLoginForm(context);
        },
        listener: (BuildContext context, LoginState state) {
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('登录成功')));
            context.go(AppRouter.home);
          }

          if (state is LoginFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '使用邮箱登录',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _emailWidget(),
          _passwordWidget(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;
                  context.read<LoginBloc>().add(
                    LoginEvent.loginPressed(
                      username: email,
                      password: password,
                    ),
                  );
                  _log.info('login $email');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: Text('登录', style: _styleInput),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.push(AppRouter.register),
            child: const Text('还没有账号？去注册'),
          ),
        ],
      ),
    );
  }

  final _styleInput = const TextStyle(color: Colors.black, fontSize: 20);

  Widget _emailWidget() {
    return InputWidget(
      controller: _emailController,
      labelText: '邮箱',
      inputType: TextInputType.emailAddress,
      maxLength: 64,
      config: InputConfig(textStyle: _styleInput),
    );
  }

  Widget _passwordWidget() {
    return InputWidget(
      controller: _passwordController,
      labelText: '密码',
      inputType: TextInputType.visiblePassword,
      maxLength: 32,
      config: InputConfig(textStyle: _styleInput),
    );
  }
}

@Preview(name: "login")
Widget getLoginWidget() {
  return const LoginPage();
}
