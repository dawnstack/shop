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
    if (event is! LoginPressed) {
      return;
    }

    emit(LoginState.loading());
    final result = await loginUsecase.login(event.username, event.password);
    emit(switch (result) {
      Success(data: final user) => LoginState.success(user),
      Failure(message: final msg) => LoginState.failure(msg),
    });
  }
}
