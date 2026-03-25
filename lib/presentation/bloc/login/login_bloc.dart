import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/domain/entities/data_result.dart';
import 'package:shop/domain/usecase/login_usecase.dart';
import 'package:shop/presentation/bloc/login/login_event.dart';
import 'package:shop/presentation/bloc/login/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase loginUsecase;

  LoginBloc(this.loginUsecase) : super(LoginState.initial()) {
    on<LoginEvent>(_onEvent);
  }

  Future<void> _onEvent(LoginEvent event, Emitter<LoginState> emit) async {
    emit(LoginState.loading());

    if (event is LoginPressed) {
      final result = await loginUsecase.login(event.username, event.password);
      emit(switch (result) {
        Success(data: final user) => LoginState.success(user, message: '登录成功'),
        Failure(message: final msg) => LoginState.failure(msg),
      });
      return;
    }

    if (event is RegisterPressed) {
      final result = await loginUsecase.register(
        event.username,
        event.password,
        nickname: event.nickname,
      );
      emit(switch (result) {
        Success(data: final user) => LoginState.success(user, message: '注册成功'),
        Failure(message: final msg) => LoginState.failure(msg),
      });
    }
  }
}
