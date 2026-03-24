import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/presentation/bloc/login/login_bloc.dart';
import 'package:shop/presentation/pages/detail_page.dart';
import 'package:shop/presentation/pages/login_page.dart';
import 'package:shop/presentation/pages/main_page.dart';

class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String detail = '/detail';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(path: home, builder: (context, state) => const MainPage()),
      GoRoute(
        path: login,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => di.getIt<LoginBloc>(),
            child: const LoginPage(),
          );
        },
      ),
      GoRoute(
        path: detail,
        builder: (context, state) {
          final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return DetailPage(
            id: args['id'],
            name: args['name'],
            imageUrl: args['imageUrl'],
            price: args['price'],
            originalPrice: args['originalPrice'],
            sales: args['sales'],
          );
        },
      ),
    ],
  );
}
