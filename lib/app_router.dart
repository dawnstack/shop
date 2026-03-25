import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/presentation/bloc/login/login_bloc.dart';
import 'package:shop/presentation/pages/address_page.dart';
import 'package:shop/presentation/pages/detail_page.dart';
import 'package:shop/presentation/pages/login_page.dart';
import 'package:shop/presentation/pages/main_page.dart';
import 'package:shop/presentation/pages/order_detail_page.dart';
import 'package:shop/presentation/pages/orders_page.dart';
import 'package:shop/presentation/pages/register_page.dart';

class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String addresses = '/addresses';
  static const String orders = '/orders';
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
        path: register,
        builder: (context, state) {
          return BlocProvider(
            create: (_) => di.getIt<LoginBloc>(),
            child: const RegisterPage(),
          );
        },
      ),
      GoRoute(
        path: addresses,
        builder: (context, state) => const AddressPage(),
      ),
      GoRoute(path: orders, builder: (context, state) => const OrdersPage()),
      GoRoute(
        path: '$orders/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return OrderDetailPage(orderId: id);
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
