import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/constants/asset_constants.dart';
import 'package:tribalsetu/core/enums/verification_status.dart';
import 'package:tribalsetu/features/applications/controllers/verification_controller.dart';
import 'package:tribalsetu/features/applications/screens/application_verification_screen.dart';
import 'package:tribalsetu/features/applications/widgets/document_verification_list_card.dart';
import 'package:tribalsetu/features/applications/widgets/document_verification_row.dart';
import 'package:tribalsetu/features/applications/widgets/verification_info_cards.dart';
import 'package:tribalsetu/features/applications/widgets/verification_page_header.dart';
import 'package:tribalsetu/features/applications/widgets/verification_progress_widget.dart';
import 'package:tribalsetu/features/applications/widgets/verification_summary_card.dart';
import 'package:tribalsetu/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/models/application.dart';
import 'package:tribalsetu/models/verification.dart';
import 'package:tribalsetu/repositories/mock_application_repository.dart';
import 'package:tribalsetu/repositories/mock_document_repository.dart';
import 'package:tribalsetu/repositories/mock_verification_repository.dart';
import 'package:tribalsetu/repositories/verification_repository.dart';

class FailingVerificationRepository implements VerificationRepository {
  @override
  Future<List<VerificationRecord>> getApplicationVerifications(String applicationId) async {
    throw Exception('Failed to connect to verification service. Please try again.');
  }

  @override
  Future<VerificationRecord> createVerification({
    required String applicationId,
    required String documentId,
  }) async {
    throw Exception('Failed to connect to verification service. Please try again.');
  }

  @override
  Future<Map<String, dynamic>> executeVerification(String verificationId) async {
    throw Exception('Failed to connect to verification service. Please try again.');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VerificationController Unit Tests', () {
    late MockVerificationRepository verificationRepo;
    late MockApplicationRepository applicationRepo;
    late MockDocumentRepository documentRepo;
    late VerificationController controller;

    setUp(() {
      verificationRepo = MockVerificationRepository(latency: Duration.zero);
      applicationRepo = MockApplicationRepository(latency: Duration.zero);
      documentRepo = MockDocumentRepository(latency: Duration.zero);
      controller = VerificationController(
        verificationRepository: verificationRepo,
        applicationRepository: applicationRepo,
        documentRepository: documentRepo,
        applicationId: 'app-2024-st-01',
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state is correct before load', () {
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.verifications, isEmpty);
      expect(controller.application, isNull);
      expect(controller.documentsMap, isEmpty);
      expect(controller.timelineEvents, isEmpty);
    });

    test('loadData populates application, verifications, and document map', () async {
      await controller.loadData();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.application, isNotNull);
      expect(controller.application!.applicationNumber, equals('TS2024PMS10023'));
      expect(controller.verifications.length, equals(5));

      // Check lastUpdatedAt resolves from application or records
      expect(controller.lastUpdatedAt, isNotNull);
      expect(controller.lastUpdatedAt!.year, equals(2025));

      // Check document catalog resolution
      expect(controller.documentsMap.containsKey('doc-01'), isTrue);
      expect(controller.documentsMap.containsKey('doc-02'), isTrue);
      expect(controller.documentsMap.containsKey('doc-03'), isTrue);
    });

    test('getDocumentName resolves correct human-readable document names', () async {
      await controller.loadData();

      final row1 = controller.verifications[0];
      final row2 = controller.verifications[1];
      final row3 = controller.verifications[2];
      final row4 = controller.verifications[3];
      final row5 = controller.verifications[4];

      expect(controller.getDocumentName(row1), equals('Aadhaar Card'));
      expect(controller.getDocumentName(row2), equals('Caste Certificate (ST)'));
      expect(controller.getDocumentName(row3), equals('Class 12 Marksheet'));
      expect(controller.getDocumentName(row4), equals('Annual Family Income Certificate'));
      expect(controller.getDocumentName(row5), equals('Institution Admission Proof'));
    });

    test('getDocumentSubtitle resolves remarks and sources correctly', () async {
      await controller.loadData();

      expect(controller.getDocumentSubtitle(controller.verifications[0]), equals('Verified through UIDAI'));
      expect(controller.getDocumentSubtitle(controller.verifications[1]), equals('Verified through State Government'));
      expect(controller.getDocumentSubtitle(controller.verifications[2]), equals('Verified through Education Board'));
      expect(controller.getDocumentSubtitle(controller.verifications[3]), equals('Awaiting verification from Revenue Dept.'));
      expect(controller.getDocumentSubtitle(controller.verifications[4]), equals('Flagged for manual review by AISHE'));
    });

    test('Fallback mapping for getDocumentName when documentId not in map', () {
      final unmapped = VerificationRecord(
        id: 'ver-custom',
        applicationId: 'app-01',
        verificationType: 'IDENTITY',
        stageName: 'Custom Stage',
        status: VerificationStatus.verified,
      );
      expect(controller.getDocumentName(unmapped), equals('Aadhaar Card'));

      final unknown = VerificationRecord(
        id: 'ver-unknown',
        applicationId: 'app-01',
        verificationType: 'OTHER',
        stageName: 'Other Document Verification',
        status: VerificationStatus.pending,
      );
      expect(controller.getDocumentName(unknown), equals('Other Document Verification'));
    });

    test('Error handling when repository throws', () async {
      final failingController = VerificationController(
        verificationRepository: FailingVerificationRepository(),
        applicationRepository: applicationRepo,
        documentRepository: documentRepo,
        applicationId: 'app-2024-st-01',
      );

      await failingController.loadData();

      expect(failingController.isLoading, isFalse);
      expect(failingController.errorMessage, contains('Failed to connect to verification service'));

      failingController.clearError();
      expect(failingController.errorMessage, isNull);

      failingController.dispose();
    });
  });

  group('ApplicationVerificationScreen Widget & Fidelity Tests', () {
    late MockVerificationRepository verificationRepo;
    late MockApplicationRepository applicationRepo;
    late MockDocumentRepository documentRepo;
    late VerificationController controller;

    setUp(() {
      verificationRepo = MockVerificationRepository(latency: Duration.zero);
      applicationRepo = MockApplicationRepository(latency: Duration.zero);
      documentRepo = MockDocumentRepository(latency: Duration.zero);
      controller = VerificationController(
        verificationRepository: verificationRepo,
        applicationRepository: applicationRepo,
        documentRepository: documentRepo,
        applicationId: 'app-2024-st-01',
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget({VerificationController? customController, Application? initialApp}) {
      return MaterialApp(
        home: ApplicationVerificationScreen(
          controller: customController ?? controller,
          initialApplication: initialApp,
          studentInitials: 'AS',
          unreadNotificationsCount: 1,
        ),
      );
    }

    testWidgets('Renders all structural header and branding elements', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Top Decorative Tribal Asset
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == AssetConstants.topTribalPattern,
        ),
        findsOneWidget,
      );

      // 2. DashboardHeader
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('AS'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);

      // 3. VerificationPageHeader
      expect(find.byType(VerificationPageHeader), findsOneWidget);
      expect(find.text('Application Verification'), findsOneWidget);
      expect(find.text('Track the verification status of documents submitted with your application.'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('Renders VerificationSummaryCard with exact reference details', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(VerificationSummaryCard), findsOneWidget);
      expect(find.byIcon(Icons.school_rounded), findsOneWidget);
      expect(find.text('Application ID'), findsOneWidget);
      expect(find.text('TS2024PMS10023'), findsOneWidget);
      expect(find.text('UNDER VERIFICATION'), findsOneWidget);
      expect(find.text('Post Matric Scholarship for ST Students'), findsOneWidget);
      expect(find.text('Ministry of Tribal Affairs, Government of India'), findsOneWidget);
      expect(find.text('View Application'), findsOneWidget);
    });

    testWidgets('Renders VerificationProgressWidget with 4 stages and last updated timestamp', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(VerificationProgressWidget), findsOneWidget);
      expect(find.text('Verification Progress'), findsOneWidget);
      expect(find.textContaining('Last updated: 12 Dec 2025'), findsOneWidget);

      // Check all 4 progression steps
      expect(find.text('Application\nSubmitted'), findsOneWidget);
      expect(find.text('Document\nVerification'), findsOneWidget);
      expect(find.text('Department\nReview'), findsOneWidget);
      expect(find.text('Final\nDecision'), findsOneWidget);
    });

    testWidgets('Renders DocumentVerificationListCard with all 5 document rows', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DocumentVerificationListCard), findsOneWidget);
      expect(find.text('Document Verification Status'), findsOneWidget);
      expect(find.text('Live status of each document submitted with your application.'), findsOneWidget);

      expect(find.byType(DocumentVerificationRow), findsNWidgets(5));

      // Row 1: Aadhaar Card
      expect(find.text('Aadhaar Card'), findsOneWidget);
      expect(find.text('Verified through UIDAI'), findsOneWidget);

      // Row 2: Caste Certificate (ST)
      expect(find.text('Caste Certificate (ST)'), findsOneWidget);
      expect(find.text('Verified through State Government'), findsOneWidget);

      // Row 3: Class 12 Marksheet
      expect(find.text('Class 12 Marksheet'), findsOneWidget);
      expect(find.text('Verified through Education Board'), findsOneWidget);

      // Row 4: Annual Family Income Certificate
      expect(find.text('Annual Family Income Certificate'), findsOneWidget);
      expect(find.text('Awaiting verification from Revenue Dept.'), findsOneWidget);

      // Row 5: Institution Admission Proof
      expect(find.text('Institution Admission Proof'), findsOneWidget);
      expect(find.text('Flagged for manual review by AISHE'), findsOneWidget);

      // Status Pills
      expect(find.text('VERIFIED'), findsNWidgets(3));
      expect(find.text('PENDING'), findsWidgets);
      expect(find.text('MANUAL REVIEW'), findsOneWidget);
    });

    testWidgets('Renders both bottom informational callout cards', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1600 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(VerificationInfoCards), findsOneWidget);
      expect(find.text('What happens next?'), findsOneWidget);
      expect(
        find.textContaining('Once all documents are verified, your application moves to the Department Review stage.'),
        findsOneWidget,
      );
      expect(find.text('Important Information'), findsOneWidget);
      expect(
        find.textContaining('If any document requires re-upload or clarification, you will have 7 days'),
        findsOneWidget,
      );
    });

    testWidgets('Global bottom navigation bar has Applications tab active (index 2)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final navBar = tester.widget<CustomBottomNavBar>(find.byType(CustomBottomNavBar));
      expect(navBar.selectedIndex, equals(2));
    });

    testWidgets('Displays empty state cleanly when no verifications exist', (tester) async {
      final emptyController = VerificationController(
        verificationRepository: verificationRepo,
        applicationRepository: applicationRepo,
        documentRepository: documentRepo,
        applicationId: 'app-empty',
      );

      tester.view.physicalSize = const Size(390 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(customController: emptyController));
      await tester.pumpAndSettle();

      expect(find.text('No verification records available yet.'), findsOneWidget);

      emptyController.dispose();
    });

    testWidgets('Displays error state with Retry button on failure', (tester) async {
      final errorController = VerificationController(
        verificationRepository: FailingVerificationRepository(),
        applicationRepository: applicationRepo,
        documentRepository: documentRepo,
        applicationId: 'app-2024-st-01',
      );

      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(customController: errorController));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to connect to verification service'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      errorController.dispose();
    });
  });

  group('ApplicationVerificationScreen Responsive & Dimension Tests', () {
    late MockVerificationRepository verificationRepo;
    late MockApplicationRepository applicationRepo;
    late MockDocumentRepository documentRepo;
    late VerificationController controller;

    setUp(() {
      verificationRepo = MockVerificationRepository(latency: Duration.zero);
      applicationRepo = MockApplicationRepository(latency: Duration.zero);
      documentRepo = MockDocumentRepository(latency: Duration.zero);
      controller = VerificationController(
        verificationRepository: verificationRepo,
        applicationRepository: applicationRepo,
        documentRepository: documentRepo,
        applicationId: 'app-2024-st-01',
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ApplicationVerificationScreen(
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

      expect(find.text('Application Verification'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Application Verification'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768 * 2, 1024 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Application Verification'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
