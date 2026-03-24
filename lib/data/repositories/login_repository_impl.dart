import 'package:shop/data/datasources/local/token_manager.dart';
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/models/repository_helper.dart';
import 'package:shop/data/models/user_model.dart';
import 'package:shop/domain/entities/data_result.dart';
import 'package:shop/domain/entities/user_data.dart';
import 'package:shop/domain/repositories/login_repository.dart';

class LoginRepositoryImpl extends LoginRepository with RepositoryHelper {
  final ApiService _apiService;
  final TokenManager _tokenManager;

  LoginRepositoryImpl(this._apiService, this._tokenManager);

  @override
  Future<DataResult<UserData>> login(String email, String password) async {
    final result = await mapToResult<UserModel, UserData>(
      call: () => _apiService.login(email, password),
      mapToEntity: (models) => models.toEntity(),
    );

    if (result case Success(data: final user)) {
      await _tokenManager.saveSession(user);
    }

    return result;
  }
}
