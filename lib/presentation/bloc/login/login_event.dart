sealed class LoginEvent {
  const LoginEvent();

  factory LoginEvent.loginPressed({
    required String username,
    required String password,
  }) = LoginPressed;
}

final class LoginPressed extends LoginEvent {
  final String username;
  final String password;

  const LoginPressed({required this.username, required this.password});
}
