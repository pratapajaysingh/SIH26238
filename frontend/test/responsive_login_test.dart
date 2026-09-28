import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/enums/auth_method_enum.dart';
import 'package:tribalsetu/features/auth/controllers/auth_controller.dart';
import 'package:tribalsetu/features/auth/screens/login_screen.dart';
import 'package:tribalsetu/repositories/mock_auth_repository.dart';

void main() {
  group('LoginScreen Responsive & Dimension Tests (Zero Overflow Verification)', () {
    late MockAuthRepository mockRepo;
    late AuthController authController;

    setUp(() {
      mockRepo = MockAuthRepository();
      authController = AuthController(authRepository: mockRepo);
    });

    tearDown(() {
      authController.dispose();
    });

    Widget createTestWidget({required Size physicalSize, double bottomInset = 0}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: physicalSize,
            viewInsets: EdgeInsets.only(bottom: bottomInset),
            padding: const EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: LoginScreen(controller: authController),
        ),
      );
    }

    testWidgets('Renders with NO overflow on Small phone (360 x 640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(physicalSize: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Continue with DigiLocker'), findsOneWidget);
    });

    testWidgets('Renders with NO overflow on Standard phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(physicalSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Student'), findsOneWidget);
    });

    testWidgets('Renders with NO overflow on Large phone (430 x 932)', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(physicalSize: const Size(430, 932)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Student'), findsOneWidget);
    });

    testWidgets('Renders with NO overflow when virtual keyboard opens (bottom inset 300px)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(
        physicalSize: const Size(390, 844),
        bottomInset: 300,
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verify that scrolling works smoothly
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Validation state displays error message when mobile is empty or invalid', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(physicalSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      // Tap continue with empty field
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your mobile number'), findsOneWidget);
      expect(authController.errorMessage, 'Please enter your mobile number');
    });

    testWidgets('Aadhaar method switch displays Aadhaar input field', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(physicalSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      // Tap Aadhaar tab
      await tester.tap(find.text('Aadhaar'));
      await tester.pumpAndSettle();

      expect(authController.selectedMethod, AuthMethod.aadhaar);
      expect(find.text('Enter your 12-digit Aadhaar number'), findsOneWidget);
    });
  });
}
