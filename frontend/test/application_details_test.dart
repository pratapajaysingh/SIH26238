import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/constants/asset_constants.dart';
import 'package:tribalsetu/core/enums/application_status.dart';
import 'package:tribalsetu/core/enums/payment_status.dart';
import 'package:tribalsetu/features/applications/controllers/application_details_controller.dart';
import 'package:tribalsetu/features/applications/screens/application_details_screen.dart';
import 'package:tribalsetu/features/applications/widgets/application_details_page_header.dart';
import 'package:tribalsetu/features/applications/widgets/application_jago_help_banner.dart';
import 'package:tribalsetu/features/applications/widgets/application_overview_card.dart';
import 'package:tribalsetu/features/applications/widgets/application_payment_status_card.dart';
import 'package:tribalsetu/features/applications/widgets/application_progress_stepper.dart';
import 'package:tribalsetu/features/applications/widgets/application_section_tabs.dart';
import 'package:tribalsetu/features/applications/widgets/application_submitted_documents_card.dart';
import 'package:tribalsetu/features/applications/widgets/application_verification_status_card.dart';
import 'package:tribalsetu/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/models/application.dart';
import 'package:tribalsetu/models/application_timeline.dart';
import 'package:tribalsetu/repositories/application_repository.dart';
import 'package:tribalsetu/repositories/mock_application_repository.dart';
import 'package:tribalsetu/repositories/mock_document_repository.dart';
import 'package:tribalsetu/repositories/mock_payment_repository.dart';
import 'package:tribalsetu/repositories/mock_verification_repository.dart';

class FailingApplicationRepository implements ApplicationRepository {
  @override
  Future<List<Application>> getApplications() async => throw Exception('Network error');
  @override
  Future<Application?> getActiveApplication() async => throw Exception('Network error');
  @override
  Future<List<ApplicationTimelineEvent>> getApplicationTimeline(String applicationId) async =>
      throw Exception('Network error');
  @override
  Future<Application?> getApplicationById(String id) async => throw Exception('Failed to load application details');
  @override
  Future<Application> createApplication({required String schemeId, required String academicYear}) async =>
      throw Exception('Network error');
  @override
  Future<Application> updateApplication(String applicationId, Map<String, dynamic> data) async =>
      throw Exception('Network error');
  @override
  Future<Application> submitApplication(String applicationId) async =>
      throw Exception('Network error');
  @override
  Future<bool> attachDocument(String applicationId, String documentId) async =>
      throw Exception('Network error');
  @override
  Future<bool> removeDocument(String applicationId, String documentId) async =>
      throw Exception('Network error');
  @override
  Future<List<String>> getApplicationDocumentIds(String applicationId) async =>
      throw Exception('Network error');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApplicationDetailsController Unit & State Tests', () {
    late MockApplicationRepository appRepo;
    late MockVerificationRepository verRepo;
    late MockPaymentRepository payRepo;
    late MockDocumentRepository docRepo;
    late ApplicationDetailsController controller;

    setUp(() {
      appRepo = MockApplicationRepository(latency: Duration.zero);
      verRepo = MockVerificationRepository(latency: Duration.zero);
      payRepo = MockPaymentRepository(latency: Duration.zero);
      docRepo = MockDocumentRepository(latency: Duration.zero);
      controller = ApplicationDetailsController(
        applicationRepository: appRepo,
        verificationRepository: verRepo,
        paymentRepository: payRepo,
        documentRepository: docRepo,
        applicationId: 'app-2024-st-01',
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state: not loading, no error, overview tab active', () {
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.selectedTab, equals(ApplicationDetailsTab.overview));
      expect(controller.application, isNull);
      expect(controller.timelineEvents, isEmpty);
      expect(controller.verifications, isEmpty);
      expect(controller.payments, isEmpty);
      expect(controller.documents, isEmpty);
    });

    test('loadData populates all contract resources concurrently', () async {
      await controller.loadData();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.application, isNotNull);
      expect(controller.application!.applicationNumber, equals('TS2024PMS10023'));
      expect(controller.timelineEvents, isNotEmpty);
      expect(controller.verifications.length, equals(5));
      expect(controller.payments, isNotEmpty);
      expect(controller.documents.length, equals(6));
      expect(controller.academicYear, equals('2024 - 2025'));
      expect(controller.primaryPayment, isNotNull);
      expect(controller.primaryPayment!.amount, equals(48000.0));
    });

    test('setTab switches presentation sections correctly', () {
      controller.setTab(ApplicationDetailsTab.documents);
      expect(controller.selectedTab, equals(ApplicationDetailsTab.documents));

      controller.setTab(ApplicationDetailsTab.timeline);
      expect(controller.selectedTab, equals(ApplicationDetailsTab.timeline));

      controller.setTab(ApplicationDetailsTab.payments);
      expect(controller.selectedTab, equals(ApplicationDetailsTab.payments));

      controller.setTab(ApplicationDetailsTab.overview);
      expect(controller.selectedTab, equals(ApplicationDetailsTab.overview));
    });

    test('Status mapping helpers return correct labels', () {
      expect(controller.getApplicationStatusLabel(ApplicationStatus.inVerification), equals('Under Verification'));
      expect(controller.getApplicationStatusLabel(ApplicationStatus.submitted), equals('Submitted'));
      expect(controller.getApplicationStatusLabel(ApplicationStatus.deficiency), equals('Action Required'));
      expect(controller.getApplicationStatusLabel(ApplicationStatus.sanctioned), equals('Sanctioned'));

      expect(controller.getPaymentStatusLabel(PaymentStatus.processing), equals('Not Disbursed'));
      expect(controller.getPaymentStatusLabel(PaymentStatus.credited), equals('Credited'));
      expect(controller.getPaymentStatusLabel(PaymentStatus.dbtInitiated), equals('DBT Initiated'));
    });

    test('Error handling when repository throws', () async {
      final failingController = ApplicationDetailsController(
        applicationRepository: FailingApplicationRepository(),
        verificationRepository: verRepo,
        paymentRepository: payRepo,
        documentRepository: docRepo,
        applicationId: 'app-2024-st-01',
      );

      await failingController.loadData();

      expect(failingController.isLoading, isFalse);
      expect(failingController.errorMessage, contains('Failed to load application details'));

      failingController.clearError();
      expect(failingController.errorMessage, isNull);

      failingController.dispose();
    });
  });

  group('ApplicationDetailsScreen Widget & Visual Target Fidelity Tests', () {
    late MockApplicationRepository appRepo;
    late MockVerificationRepository verRepo;
    late MockPaymentRepository payRepo;
    late MockDocumentRepository docRepo;
    late ApplicationDetailsController controller;

    setUp(() {
      appRepo = MockApplicationRepository(latency: Duration.zero);
      verRepo = MockVerificationRepository(latency: Duration.zero);
      payRepo = MockPaymentRepository(latency: Duration.zero);
      docRepo = MockDocumentRepository(latency: Duration.zero);
      controller = ApplicationDetailsController(
        applicationRepository: appRepo,
        verificationRepository: verRepo,
        paymentRepository: payRepo,
        documentRepository: docRepo,
        applicationId: 'app-2024-st-01',
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget({ApplicationDetailsController? customController, Application? initialApp}) {
      return MaterialApp(
        home: ApplicationDetailsScreen(
          controller: customController ?? controller,
          initialApplication: initialApp,
          studentInitials: 'AS',
          unreadNotificationsCount: 1,
        ),
      );
    }

    testWidgets('Renders all header, branding, and tribal decoration elements', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Top Decorative Tribal Pattern
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == AssetConstants.topTribalPattern,
        ),
        findsOneWidget,
      );

      // 2. DashboardHeader
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('AS'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);

      // 3. ApplicationDetailsPageHeader
      expect(find.byType(ApplicationDetailsPageHeader), findsOneWidget);
      expect(find.text('Application Details'), findsOneWidget);
      expect(
        find.text('Track the status of your scholarship application\nand view all related information.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('Renders ApplicationOverviewCard with exact reference details', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationOverviewCard), findsOneWidget);
      expect(find.text('Post Matric Scholarship for ST Students'), findsOneWidget);
      expect(find.text('Under Verification'), findsOneWidget);
      expect(find.text('Application Number'), findsOneWidget);
      expect(find.text('TS2024PMS10023'), findsOneWidget);
      expect(find.text('Academic Year'), findsOneWidget);
      expect(find.text('2024 - 2025'), findsOneWidget);
      expect(find.text('Applied On'), findsOneWidget);
    });

    testWidgets('Renders ApplicationProgressStepper with 5 stages', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationProgressStepper), findsOneWidget);
      expect(find.text('Application Progress'), findsOneWidget);
      expect(find.text('Track your application through each stage of the process.'), findsOneWidget);

      // 5 stages
      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('Institute\nVerification'), findsOneWidget);
      expect(find.text('District\nVerification'), findsOneWidget);
      expect(find.text('Sanction'), findsOneWidget);
      expect(find.text('DBT Payment'), findsOneWidget);
      expect(find.text('In Progress'), findsWidgets);
    });

    testWidgets('Renders ApplicationSectionTabs and Overview cards', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Section tabs
      expect(find.byType(ApplicationSectionTabs), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Documents'), findsWidgets);
      expect(find.text('Timeline'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);

      // Verification Status Card
      expect(find.byType(ApplicationVerificationStatusCard), findsOneWidget);
      expect(find.text('Verification Status'), findsOneWidget);
      expect(find.text('Institute Verification'), findsWidgets);
      expect(find.text('District Verification'), findsWidgets);
      expect(find.text('State Verification'), findsOneWidget);

      // Payment / DBT Status Card
      expect(find.byType(ApplicationPaymentStatusCard), findsOneWidget);
      expect(find.text('Payment / DBT Status'), findsOneWidget);
      expect(find.text('Not Disbursed'), findsOneWidget);

      // Submitted Documents Card
      expect(find.byType(ApplicationSubmittedDocumentsCard), findsOneWidget);
      expect(find.text('Submitted Documents'), findsOneWidget);
      expect(find.text('Aadhaar Card'), findsOneWidget);
      expect(find.text('Caste Certificate'), findsOneWidget);
      expect(find.text('Income Certificate'), findsOneWidget);

      // Ask JAGO Help Banner
      expect(find.byType(ApplicationJagoHelpBanner), findsOneWidget);
      expect(find.text('Need Help with Your Application?'), findsOneWidget);
      expect(find.text('Ask JAGO'), findsOneWidget);
    });

    testWidgets('Tapping section tabs switches views smoothly', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1600 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap "Documents" tab
      await tester.tap(find.descendant(of: find.byType(ApplicationSectionTabs), matching: find.text('Documents')));
      await tester.pumpAndSettle();

      expect(find.text('Attached Documents'), findsOneWidget);

      // Tap "Timeline" tab
      await tester.tap(find.descendant(of: find.byType(ApplicationSectionTabs), matching: find.text('Timeline')));
      await tester.pumpAndSettle();

      expect(find.text('Application History'), findsOneWidget);

      // Tap "Payments" tab
      await tester.tap(find.descendant(of: find.byType(ApplicationSectionTabs), matching: find.text('Payments')));
      await tester.pumpAndSettle();

      expect(find.text('Disbursement Ledger'), findsOneWidget);

      // Tap "Overview" tab to return
      await tester.tap(find.descendant(of: find.byType(ApplicationSectionTabs), matching: find.text('Overview')));
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationVerificationStatusCard), findsOneWidget);
    });

    testWidgets('Global bottom navigation has Applications active (index 2)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final navBar = tester.widget<CustomBottomNavBar>(find.byType(CustomBottomNavBar));
      expect(navBar.selectedIndex, equals(2));
    });

    testWidgets('Displays error state with retry on failure', (tester) async {
      final errorController = ApplicationDetailsController(
        applicationRepository: FailingApplicationRepository(),
        verificationRepository: verRepo,
        paymentRepository: payRepo,
        documentRepository: docRepo,
        applicationId: 'app-2024-st-01',
      );

      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(customController: errorController));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to load application details'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      errorController.dispose();
    });
  });

  group('ApplicationDetailsScreen Responsive & Dimension Tests', () {
    late MockApplicationRepository appRepo;
    late MockVerificationRepository verRepo;
    late MockPaymentRepository payRepo;
    late MockDocumentRepository docRepo;
    late ApplicationDetailsController controller;

    setUp(() {
      appRepo = MockApplicationRepository(latency: Duration.zero);
      verRepo = MockVerificationRepository(latency: Duration.zero);
      payRepo = MockPaymentRepository(latency: Duration.zero);
      docRepo = MockDocumentRepository(latency: Duration.zero);
      controller = ApplicationDetailsController(
        applicationRepository: appRepo,
        verificationRepository: verRepo,
        paymentRepository: payRepo,
        documentRepository: docRepo,
        applicationId: 'app-2024-st-01',
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ApplicationDetailsScreen(
          controller: controller,
          studentInitials: 'AS',
          unreadNotificationsCount: 1,
        ),
      );
    }

    testWidgets('Zero overflow on Small Phone (360 x 640)', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Application Details'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Application Details'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768 * 2, 1024 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Application Details'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
