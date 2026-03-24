import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/common/constants/api_constants.dart';
import 'package:shop/common/network/interceptors/auth_interceptor.dart';
import 'package:shop/common/network/interceptors/log_interceptor.dart'
    as app_interceptor;
import 'package:shop/data/datasources/local/local_storage.dart';
import 'package:shop/data/datasources/local/token_manager.dart';
import 'package:shop/data/datasources/remote/api_service.dart';
import 'package:shop/data/repositories/home_repository_impl.dart';
import 'package:shop/domain/repositories/home_repository.dart';
import 'package:shop/domain/repositories/login_repository.dart';
import 'package:shop/domain/usecase/home_usecase.dart';
import 'package:shop/domain/usecase/impl/home_usecase_impl.dart';
import 'package:shop/domain/usecase/impl/login_usecase_impl.dart';
import 'package:shop/domain/usecase/login_usecase.dart';
import 'package:shop/data/repositories/login_repository_impl.dart';
import 'package:shop/presentation/bloc/home/home_bloc.dart';
import 'package:shop/presentation/bloc/login/login_bloc.dart';

var getIt = GetIt.I;

Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage(getIt()));
  getIt.registerLazySingleton<TokenManager>(() => TokenManager(getIt()));
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(getIt<TokenManager>()),
      app_interceptor.LogInterceptor(),
    ]);
    return dio;
  });
  getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>()));

  getIt.registerLazySingleton<LoginRepository>(
    () => LoginRepositoryImpl(getIt<ApiService>(), getIt<TokenManager>()),
  );
  getIt.registerLazySingleton<LoginUsecase>(
    () => LoginUsecaseImpl(getIt<LoginRepository>()),
  );
  getIt.registerFactory<LoginBloc>(() => LoginBloc(getIt<LoginUsecase>()));

  getIt.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<HomeUsecase>(
    () => HomeUsecaseImpl(getIt<HomeRepository>()),
  );
  getIt.registerFactory<HomeBloc>(() => HomeBloc(getIt<HomeUsecase>()));
}
