import 'package:shop/domain/entities/user_data.dart';

sealed class LoginState {
  const LoginState();

  factory LoginState.initial() = LoginInitial;
  factory LoginState.loading() = LoginLoading;
  factory LoginState.success(UserData user) = LoginSuccess;
  factory LoginState.failure(String message) = LoginFailure;
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  final UserData user;

  const LoginSuccess(this.user);
}

final class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);
}
