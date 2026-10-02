import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/service_locator.dart';
import 'core/enums/role_enum.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'routing/app_router.dart';

void main() async {
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
  // ┌────────────────────────────────────────────────────────────────────────┐
  // │ To connect to local FastAPI backend on fixed Chrome port:              │
  // │   flutter run -d chrome --web-port 5000 \                              │
  // │     --dart-define=USE_MOCK=false \                                     │
  // │     --dart-define=API_BASE_URL=http://localhost:8000                   │
  // │                                                                        │
  // │ To deploy to production (zero code changes):                           │
  // │   flutter run --dart-define=USE_MOCK=false \                           │
  // │     --dart-define=API_BASE_URL=https://api.yourdomain.com              │
  // └────────────────────────────────────────────────────────────────────────┘
  final sl = ServiceLocator.instance;

  // On app launch: check if stored session exists
  final initialSession = await sl.authRepository.getCurrentSession();

  final authController = AuthController(
    authRepository: sl.authRepository,
    initialSession: initialSession,
  );
  final appRouter = AppRouter(authController: authController);

  // If a valid stored token exists, go straight to the home/dashboard screen
  final String initialRoute = initialSession != null
      ? (initialSession.user.role == UserRole.admin ? '/admin' : '/dashboard')
      : '/login';

  runApp(TribalSetuApp(
    appRouter: appRouter,
    initialRoute: initialRoute,
  ));
}

/// Root widget for TribalSetu Application
class TribalSetuApp extends StatelessWidget {
  final AppRouter appRouter;
  final String initialRoute;

  const TribalSetuApp({
    super.key,
    required this.appRouter,
    this.initialRoute = '/login',
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TribalSetu - Ministry of Tribal Affairs',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      onGenerateRoute: appRouter.generateRoute,
    );
  }
}
