import 'package:go_router/go_router.dart';
import 'package:shop/presentation/pages/detail_page.dart';
import 'package:shop/presentation/pages/main_page.dart';

class AppRouter {
  static const String home = '/';
  static const String detail = '/detail';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      // 主页
      GoRoute(path: home, builder: (context, state) => const MainPage()),
      // 详情页
      GoRoute(
        path: detail,
        builder: (context, state) {
          // 移动端直接用 extra 传复杂对象（如 Map, List, 或自定义 Model）
          final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
          return DetailPage(id: args['id'], name: args['name']);
        },
      ),
    ],
  );
}
