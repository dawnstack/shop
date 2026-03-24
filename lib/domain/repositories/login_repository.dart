import 'package:shop/domain/entities/data_result.dart';
import 'package:shop/domain/entities/user_data.dart';

abstract class LoginRepository {
  Future<DataResult<UserData>> login(String email, String password);
}
