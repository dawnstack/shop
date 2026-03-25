sealed class LoginEvent {
  const LoginEvent();

  factory LoginEvent.loginPressed({
    required String username,
    required String password,
  }) = LoginPressed;

  factory LoginEvent.registerPressed({
    required String username,
    required String password,
    String? nickname,
  }) = RegisterPressed;
}

final class LoginPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginPressed({required this.username, required this.password});
}

final class RegisterPressed extends LoginEvent {
  final String username;
  final String password;
  final String? nickname;

  const RegisterPressed({
    required this.username,
    required this.password,
    this.nickname,
  });
}
