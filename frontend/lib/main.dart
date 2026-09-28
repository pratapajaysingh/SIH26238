import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for seamless government mobile experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize repository layer via centralized ServiceLocator.
  // ┌─────────────────────────────────────────────────────────┐
  // │ To connect to real backend, run with:                   │
  // │   flutter run --dart-define=USE_MOCK=false              │
  // │   flutter run --dart-define=API_BASE_URL=http://x.x.x.x│
  // │                                                         │
  // │ Or change useMock=false in service_locator.dart         │
  // └─────────────────────────────────────────────────────────┘
  final sl = ServiceLocator.instance;
  final authController = AuthController(authRepository: sl.authRepository);
  final appRouter = AppRouter(authController: authController);

  runApp(TribalSetuApp(appRouter: appRouter));
}

/// Root widget for TribalSetu Application
class TribalSetuApp extends StatelessWidget {
  final AppRouter appRouter;

  const TribalSetuApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TribalSetu - Ministry of Tribal Affairs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}
