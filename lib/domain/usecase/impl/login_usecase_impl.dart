import 'package:shop/domain/entities/data_result.dart';
import 'package:shop/domain/entities/user_data.dart';
import 'package:shop/domain/repositories/login_repository.dart';
import 'package:shop/domain/usecase/login_usecase.dart';

class LoginUsecaseImpl extends LoginUsecase {
  final LoginRepository _repository;
  LoginUsecaseImpl(this._repository);

  @override
  Future<DataResult<UserData>> login(String email, String password) {
    return _repository.login(email, password);
  }
}
