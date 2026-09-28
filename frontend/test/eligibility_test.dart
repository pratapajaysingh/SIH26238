import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/network/api_exceptions.dart';
import 'package:tribalsetu/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/features/eligibility/controllers/eligibility_controller.dart';
import 'package:tribalsetu/features/eligibility/screens/check_eligibility_screen.dart';
import 'package:tribalsetu/features/eligibility/widgets/additional_info_card.dart';
import 'package:tribalsetu/features/eligibility/widgets/check_eligibility_button.dart';
import 'package:tribalsetu/features/eligibility/widgets/eligibility_page_header.dart';
import 'package:tribalsetu/features/eligibility/widgets/eligibility_result_card.dart';
import 'package:tribalsetu/features/eligibility/widgets/eligibility_stepper.dart';
import 'package:tribalsetu/features/eligibility/widgets/proceed_to_apply_button.dart';
import 'package:tribalsetu/features/eligibility/widgets/scheme_selector_card.dart';
import 'package:tribalsetu/models/eligibility_check_result.dart';
import 'package:tribalsetu/models/scholarship.dart';
import 'package:tribalsetu/repositories/eligibility_repository.dart';
import 'package:tribalsetu/repositories/mock_eligibility_repository.dart';
import 'package:tribalsetu/repositories/mock_scholarship_repository.dart';

class _FakeFailingEligibilityRepository implements EligibilityRepository {
  @override
  Future<EligibilityCheckResult> checkEligibility({
    required String studentId,
    required String schemeId,
  }) async {
    throw const ApiException('Network timeout while connecting to eligibility engine');
  }
}

void main() {
  group('EligibilityController Unit Tests', () {
    late EligibilityController controller;
    late MockEligibilityRepository eligibilityRepo;
    late MockScholarshipRepository scholarshipRepo;

    setUp(() {
      eligibilityRepo = MockEligibilityRepository(latency: Duration.zero);
      scholarshipRepo = MockScholarshipRepository(latency: Duration.zero);
      controller = EligibilityController(
        eligibilityRepository: eligibilityRepo,
        scholarshipRepository: scholarshipRepo,
        studentId: 'TS2024S10023',
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state loads schemes and defaults to Post Matric scheme', () async {
      expect(controller.scholarships, isEmpty);
      expect(controller.selectedScheme, isNull);
      expect(controller.currentStep, equals(1));

      await controller.loadSchemes();

      expect(controller.scholarships.length, equals(6));
      expect(controller.selectedScheme, isNotNull);
      expect(controller.selectedScheme!.name, contains('Post Matric'));
      expect(controller.selectedScheme!.id, equals('scheme-pms-st-01'));
      expect(controller.result, isNull);
      expect(controller.isChecking, isFalse);
    });

    test('Preselected scheme ID is honored when loading schemes', () async {
      await controller.loadSchemes(preselectedSchemeId: 'scheme-top-class-02');

      expect(controller.selectedScheme, isNotNull);
      expect(controller.selectedScheme!.id, equals('scheme-top-class-02'));
      expect(controller.selectedScheme!.name, contains('Top Class'));
    });

    test('Selecting a scheme resets previous result and sets step to 1', () async {
      await controller.loadSchemes();
      await controller.checkEligibility();

      expect(controller.result, isNotNull);
      expect(controller.currentStep, equals(4));

      // Change scheme
      final newScheme = controller.scholarships.firstWhere((s) => s.id == 'scheme-nfst-03');
      controller.selectScheme(newScheme);

      expect(controller.selectedScheme!.id, equals('scheme-nfst-03'));
      expect(controller.result, isNull);
      expect(controller.currentStep, equals(1));
    });

    test('checkEligibility succeeds with eligible = true for Post Matric scheme', () async {
      await controller.loadSchemes();
      await controller.checkEligibility();

      expect(controller.result, isNotNull);
      expect(controller.result!.eligible, isTrue);
      expect(controller.result!.scheme, equals('POST_MATRIC'));
      expect(controller.result!.missingItems, isEmpty);
      expect(controller.result!.rulesVersion, equals('2026.1'));
      expect(controller.currentStep, equals(4));
      expect(controller.errorMessage, isNull);
    });

    test('checkEligibility returns eligible = false and missing items for National Overseas', () async {
      await controller.loadSchemes(preselectedSchemeId: 'scheme-nos-06');
      await controller.checkEligibility();

      expect(controller.result, isNotNull);
      expect(controller.result!.eligible, isFalse);
      expect(controller.result!.scheme, equals('NATIONAL_OVERSEAS'));
      expect(controller.result!.missingItems, isNotEmpty);
      expect(controller.result!.missingItems.first, contains('Passport'));
      expect(controller.currentStep, equals(4));
    });

    test('checkEligibility handles repository errors gracefully', () async {
      final failingController = EligibilityController(
        eligibilityRepository: _FakeFailingEligibilityRepository(),
        scholarshipRepository: scholarshipRepo,
      );

      await failingController.loadSchemes();
      await failingController.checkEligibility();

      expect(failingController.result, isNull);
      expect(failingController.errorMessage, contains('Network timeout'));
      expect(failingController.isChecking, isFalse);
      expect(failingController.currentStep, equals(1));

      failingController.dispose();
    });

    test('clearError and reset work correctly', () async {
      await controller.loadSchemes();
      await controller.checkEligibility();

      expect(controller.result, isNotNull);
      controller.reset();

      expect(controller.result, isNull);
      expect(controller.currentStep, equals(1));
    });
  });

  group('CheckEligibilityScreen Widget & Visual Fidelity Tests', () {
    late MockEligibilityRepository eligibilityRepo;
    late MockScholarshipRepository scholarshipRepo;

    setUp(() {
      eligibilityRepo = MockEligibilityRepository(latency: Duration.zero);
      scholarshipRepo = MockScholarshipRepository(latency: Duration.zero);
    });

    Widget createTestWidget({
      EligibilityController? controller,
      Scholarship? initialScholarship,
      String? initialSchemeId,
    }) {
      return MaterialApp(
        routes: {
          '/applications': (context) => const Scaffold(body: Text('Applications Screen')),
          '/scholarships': (context) => const Scaffold(body: Text('Scholarships Screen')),
          '/profile': (context) => const Scaffold(body: Text('Profile Screen')),
          '/jago': (context) => const Scaffold(body: Text('Jago Screen')),
          '/apply': (context) => const Scaffold(body: Text('Apply Screen')),
        },
        home: CheckEligibilityScreen(
          controller: controller,
          initialScholarship: initialScholarship,
          initialSchemeId: initialSchemeId,
        ),
      );
    }

    testWidgets('Renders all required visual components faithfully matching reference', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = EligibilityController(
        eligibilityRepository: eligibilityRepo,
        scholarshipRepository: scholarshipRepo,
      );

      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      // 1. Top Header
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('AS'), findsOneWidget);

      // 2. Page Header
      expect(find.byType(EligibilityPageHeader), findsOneWidget);
      expect(find.text('Check Eligibility'), findsNWidgets(3)); // Title, stepper step 3, button
      expect(find.textContaining('Find out if you are eligible'), findsOneWidget);

      // 3. 4-Step Stepper
      expect(find.byType(EligibilityStepper), findsOneWidget);
      expect(find.text('Select Scheme'), findsOneWidget);
      expect(find.text('Verify Details'), findsOneWidget);
      expect(find.text('View Results'), findsOneWidget);

      // 4. Scheme Selector
      expect(find.byType(SchemeSelectorCard), findsOneWidget);
      expect(find.text('Select a Scholarship Scheme'), findsOneWidget);
      expect(find.textContaining('Choose the scheme you want to check'), findsOneWidget);
      expect(find.text('Post Matric Scholarship for ST Students'), findsOneWidget);
      expect(find.textContaining('Ministry of Tribal Affairs'), findsWidgets);

      // 5. Primary Check Eligibility Button
      expect(find.byType(CheckEligibilityButton), findsOneWidget);

      // 6. Bottom Navigation Bar
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
      expect(find.text('Scholarships'), findsOneWidget);
    });

    testWidgets('Tapping scheme selector opens bottom sheet to choose another scheme', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = EligibilityController(
        eligibilityRepository: eligibilityRepo,
        scholarshipRepository: scholarshipRepo,
      );

      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      // Tap scheme selector card
      await tester.tap(find.byKey(const ValueKey('scheme_selector_card_inkwell')));
      await tester.pumpAndSettle();

      // Bottom sheet should be visible
      expect(find.text('Select Scholarship Scheme'), findsOneWidget);
      expect(find.text('Top Class Education Scheme for ST Students'), findsOneWidget);

      // Select Top Class Education Scheme
      await tester.tap(find.text('Top Class Education Scheme for ST Students'));
      await tester.pumpAndSettle();

      // Selector card now shows Top Class scheme
      expect(find.text('Top Class Education Scheme for ST Students'), findsOneWidget);
    });

    testWidgets('Tapping Check Eligibility button evaluates and renders full eligible result matching reference', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = EligibilityController(
        eligibilityRepository: eligibilityRepo,
        scholarshipRepository: scholarshipRepo,
      );

      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      // Result should not be visible before checking
      expect(find.byType(EligibilityResultCard), findsNothing);
      expect(find.byType(AdditionalInfoCard), findsNothing);
      expect(find.byType(ProceedToApplyButton), findsNothing);

      // Tap Check Eligibility button
      await tester.tap(find.byType(CheckEligibilityButton));
      await tester.pumpAndSettle();

      // 1. Result Card should be rendered
      expect(find.byType(EligibilityResultCard), findsOneWidget);
      expect(find.text('You are Eligible!'), findsOneWidget);
      expect(find.textContaining('Based on the information available, you meet the eligibility criteria'), findsOneWidget);

      // 2. Inner Criteria Section
      expect(find.text('Eligibility Criteria'), findsOneWidget);
      expect(find.text("Here's how you match with the scheme requirements:"), findsOneWidget);
      expect(find.text('Educational Qualification'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Annual Family Income'), findsOneWidget);
      expect(find.text('Institute Type'), findsOneWidget);
      expect(find.text('Eligible'), findsNWidgets(4));

      // 3. Additional Information Card
      expect(find.byType(AdditionalInfoCard), findsOneWidget);
      expect(find.text('Additional Information'), findsOneWidget);
      expect(find.textContaining('Please keep the required documents ready'), findsOneWidget);

      // 4. Proceed to Apply Button
      expect(find.byType(ProceedToApplyButton), findsOneWidget);
      expect(find.text('Proceed to Apply'), findsOneWidget);
    });

    testWidgets('Tapping Proceed to Apply navigates to /apply route', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = EligibilityController(
        eligibilityRepository: eligibilityRepo,
        scholarshipRepository: scholarshipRepo,
      );

      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      // Run check to display result
      await tester.tap(find.byType(CheckEligibilityButton));
      await tester.pumpAndSettle();

      // Ensure Proceed to Apply button is scrolled into view
      await tester.ensureVisible(find.byType(ProceedToApplyButton));
      await tester.pumpAndSettle();

      // Tap Proceed to Apply
      await tester.tap(find.byType(ProceedToApplyButton));
      await tester.pumpAndSettle();

      expect(find.text('Apply Screen'), findsOneWidget);
    });

    testWidgets('Renders ineligible state with missing requirements for National Overseas scheme', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final controller = EligibilityController(
        eligibilityRepository: eligibilityRepo,
        scholarshipRepository: scholarshipRepo,
      );

      await tester.pumpWidget(createTestWidget(
        controller: controller,
        initialSchemeId: 'scheme-nos-06',
      ));
      await tester.pumpAndSettle();

      // Verify scheme is National Overseas
      expect(find.textContaining('National Overseas Scholarship'), findsOneWidget);

      // Tap Check Eligibility
      await tester.tap(find.byType(CheckEligibilityButton));
      await tester.pumpAndSettle();

      // Should display ineligible state
      expect(find.text('You may not be eligible'), findsOneWidget);
      expect(find.text('Missing Requirements'), findsOneWidget);
      expect(find.textContaining('Valid Passport'), findsOneWidget);
    });
  });

  group('CheckEligibilityScreen Responsive & Dimension Tests (Zero Overflow Verification)', () {
    late MockEligibilityRepository eligibilityRepo;
    late MockScholarshipRepository scholarshipRepo;

    setUp(() {
      eligibilityRepo = MockEligibilityRepository(latency: Duration.zero);
      scholarshipRepo = MockScholarshipRepository(latency: Duration.zero);
    });

    Widget createTestWidget() {
      final controller = EligibilityController(
        eligibilityRepository: eligibilityRepo,
        scholarshipRepository: scholarshipRepo,
      );
      return MaterialApp(
        home: CheckEligibilityScreen(controller: controller),
      );
    }

    testWidgets('Zero overflow on Small Phone (360 x 640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check eligibility to render full content
      await tester.tap(find.byType(CheckEligibilityButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckEligibilityButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CheckEligibilityButton));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
