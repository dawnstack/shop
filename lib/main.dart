import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/app_router.dart';
import 'package:shop/common/di/injection_container.dart' as di;
import 'package:shop/common/utils/app_logger.dart';
import 'package:shop/presentation/bloc/home/home_bloc.dart';
import 'package:shop/gen/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @Preview()
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (BuildContext context) => di.getIt<HomeBloc>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812), // 填你 UI 给的设计稿尺寸
        minTextAdapt: true,
        splitScreenMode: true,
        child: _getWidget(),
      ),
    );
  }

  MaterialApp _getWidget() {
    return MaterialApp.router(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      title: 'Namer App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 9, 108, 146),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
