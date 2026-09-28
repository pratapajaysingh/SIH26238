import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/enums/role_enum.dart';
import 'package:tribalsetu/features/auth/controllers/auth_controller.dart';
import 'package:tribalsetu/main.dart';
import 'package:tribalsetu/repositories/mock_auth_repository.dart';
import 'package:tribalsetu/routing/app_router.dart';

void main() {
  testWidgets('TribalSetu Login Screen renders all required components faithfully', (WidgetTester tester) async {
    final mockRepo = MockAuthRepository();
    final authController = AuthController(authRepository: mockRepo);
    final appRouter = AppRouter(authController: authController);

    await tester.pumpWidget(TribalSetuApp(appRouter: appRouter));
    await tester.pumpAndSettle();

    // Verify Roles
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Institute'), findsOneWidget);

    // Verify Login Methods
    expect(find.text('Mobile Number'), findsOneWidget);
    expect(find.text('Aadhaar'), findsOneWidget);

    // Verify Action Cards
    expect(find.text('Continue with DigiLocker'), findsOneWidget);
    expect(find.text('Continue with APAAR'), findsOneWidget);

    // Verify Bottom Motto
    expect(find.text('Education  •  Opportunity  •  Empowerment'), findsOneWidget);

    // Verify Default Selection
    expect(authController.selectedRole, UserRole.student);
  });
}
