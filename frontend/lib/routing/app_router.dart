import '../core/enums/role_enum.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/applications/screens/my_applications_screen.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/scholarships/screens/find_scholarships_screen.dart';
import '../features/jago/screens/jago_screen.dart';

import '../features/profile/screens/my_profile_screen.dart';
import '../features/eligibility/screens/check_eligibility_screen.dart';
import '../features/applications/screens/application_verification_screen.dart';
import '../features/applications/screens/application_details_screen.dart';
import '../features/payments/screens/payment_status_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/documents/screens/my_documents_screen.dart';
import '../features/scholarships/screens/scholarship_details_screen.dart';
import '../features/applications/screens/application_form_screen.dart';
import '../models/application.dart';
import '../models/scholarship.dart';

/// AppRouter defines top-level route generation and navigation mapping.
class AppRouter {
  final AuthController authController;

  AppRouter({required this.authController});

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
      case '/':
        return MaterialPageRoute(
          builder: (_) => LoginScreen(controller: authController),
          settings: settings,
        );

      case '/admin':
      case '/admin/dashboard':
        // Role guard: student users must not reach admin routes
        if (authController.session?.user.role == UserRole.student &&
            authController.selectedRole == UserRole.student) {
          return MaterialPageRoute(
            builder: (_) => DashboardScreen(authController: authController),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => AdminDashboardScreen(authController: authController),
          settings: settings,
        );

      case '/dashboard':
        return MaterialPageRoute(
          builder: (_) => DashboardScreen(authController: authController),
          settings: settings,
        );

      case '/scholarships':
        return MaterialPageRoute(
          builder: (_) => const FindScholarshipsScreen(),
          settings: settings,
        );

      case '/applications':
        return MaterialPageRoute(
          builder: (_) => const MyApplicationsScreen(),
          settings: settings,
        );

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => const MyProfileScreen(),
          settings: settings,
        );

      case '/jago':
        return MaterialPageRoute(
          builder: (_) => const JagoScreen(),
          settings: settings,
        );

      case '/eligibility':
        final args = settings.arguments;
        Scholarship? initialScholarship;
        String? initialSchemeId;
        if (args is Scholarship) {
          initialScholarship = args;
        } else if (args is String) {
          initialSchemeId = args;
        }
        return MaterialPageRoute(
          builder: (_) => CheckEligibilityScreen(
            initialScholarship: initialScholarship,
            initialSchemeId: initialSchemeId,
          ),
          settings: settings,
        );

      case '/verification':
        final args = settings.arguments;
        Application? initialApplication;
        String? applicationId;
        if (args is Application) {
          initialApplication = args;
          applicationId = args.id;
        } else if (args is String) {
          applicationId = args;
        }
        return MaterialPageRoute(
          builder: (_) => ApplicationVerificationScreen(
            initialApplication: initialApplication,
            applicationId: applicationId,
          ),
          settings: settings,
        );

      case '/application-details':
        final args = settings.arguments;
        Application? initialApplication;
        String? applicationId;
        if (args is Application) {
          initialApplication = args;
          applicationId = args.id;
        } else if (args is String) {
          applicationId = args;
        }
        return MaterialPageRoute(
          builder: (_) => ApplicationDetailsScreen(
            initialApplication: initialApplication,
            applicationId: applicationId,
          ),
          settings: settings,
        );

      case '/payment-status':
        final args = settings.arguments;
        Application? initialApplication;
        String? applicationId;
        if (args is Application) {
          initialApplication = args;
          applicationId = args.id;
        } else if (args is String) {
          applicationId = args;
        }
        return MaterialPageRoute(
          builder: (_) => PaymentStatusScreen(
            initialApplication: initialApplication,
            applicationId: applicationId,
          ),
          settings: settings,
        );

      case '/notifications':
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );

      case '/documents':
        return MaterialPageRoute(
          builder: (_) => const MyDocumentsScreen(),
          settings: settings,
        );

      case '/scholarship-details':
        final args = settings.arguments;
        Scholarship? initialScholarship;
        String? schemeId;
        if (args is Scholarship) {
          initialScholarship = args;
        } else if (args is String) {
          schemeId = args;
        }
        return MaterialPageRoute(
          builder: (_) => ScholarshipDetailsScreen(
            initialScholarship: initialScholarship,
            schemeId: schemeId,
          ),
          settings: settings,
        );

      case '/apply':
        final args = settings.arguments;
        Scholarship? scholarship;
        if (args is Scholarship) {
          scholarship = args;
        }
        return MaterialPageRoute(
          builder: (_) => ApplicationFormScreen(
            scholarship: scholarship,
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
