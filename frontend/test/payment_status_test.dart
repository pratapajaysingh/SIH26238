import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/enums/payment_status.dart';
import 'package:tribalsetu/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/features/payments/controllers/payment_status_controller.dart';
import 'package:tribalsetu/features/payments/screens/payment_status_screen.dart';
import 'package:tribalsetu/features/payments/widgets/payment_application_summary_card.dart';
import 'package:tribalsetu/features/payments/widgets/payment_details_card.dart';
import 'package:tribalsetu/features/payments/widgets/payment_info_callout_cards.dart';
import 'package:tribalsetu/features/payments/widgets/payment_processing_callout_card.dart';
import 'package:tribalsetu/features/payments/widgets/payment_progress_stepper.dart';
import 'package:tribalsetu/features/payments/widgets/payment_status_page_header.dart';
import 'package:tribalsetu/models/application.dart';
import 'package:tribalsetu/models/payment.dart';
import 'package:tribalsetu/repositories/mock_application_repository.dart';
import 'package:tribalsetu/repositories/mock_payment_repository.dart';
import 'package:tribalsetu/repositories/payment_repository.dart';

class FailingPaymentRepository implements PaymentRepository {
  @override
  Future<List<PaymentRecord>> getApplicationPayments(String applicationId) async {
    throw Exception('Failed to connect to DBT payment gateway.');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PaymentStatusController Unit Tests', () {
    late MockPaymentRepository paymentRepo;
    late MockApplicationRepository applicationRepo;
    late PaymentStatusController controller;

    setUp(() {
      paymentRepo = MockPaymentRepository(latency: Duration.zero);
      applicationRepo = MockApplicationRepository(latency: Duration.zero);
      controller = PaymentStatusController(
        paymentRepository: paymentRepo,
        applicationRepository: applicationRepo,
        applicationId: 'app-2026-st-01',
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state is correct before load', () {
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.payments, isEmpty);
      expect(controller.application, isNull);
    });

    test('loadData populates application and payments', () async {
      await controller.loadData();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.application, isNotNull);
      expect(controller.application!.applicationNumber, equals('TS2026ST000123'));
      expect(controller.payments.length, equals(1));

      final primary = controller.primaryPayment;
      expect(primary, isNotNull);
      expect(primary!.externalPaymentId, equals('TRI-2026-0009876'));
      expect(primary.transactionRef, equals('TRI-PAY-2026-001234'));
      expect(primary.amount, equals(48000.0));
      expect(primary.status, equals(PaymentStatus.processing));
    });

    test('Formatted getters format data accurately', () async {
      await controller.loadData();

      expect(controller.amountFormatted, equals('₹ 48,000'));
      expect(controller.sanctionOrderNumber, equals('TRI-2026-0009876'));
      expect(controller.sanctionDateFormatted, equals('10 Jan 2026'));
      expect(controller.paymentMethod, equals('Direct Benefit Transfer (DBT)'));
      expect(controller.bankAccountName, equals('State Bank of India'));
      expect(controller.maskedAccountNumber, equals('XXXX XXXX 1234'));
      expect(controller.expectedCreditDateText, equals('Within 7–10 working days'));
      expect(controller.paymentReference, equals('TRI-PAY-2026-001234'));
      expect(controller.paymentReferenceDateFormatted, contains('10 Jan 2026'));
    });

    test('Progress steps generated properly for processing status', () async {
      await controller.loadData();

      final steps = controller.progressSteps;
      expect(steps.length, equals(4));

      // Step 1: Application Approved (Completed)
      expect(steps[0].title, equals('Application\nApproved'));
      expect(steps[0].status, equals(PaymentStepStatus.completed));

      // Step 2: Sanction Released (Completed)
      expect(steps[1].title, equals('Sanction\nReleased'));
      expect(steps[1].status, equals(PaymentStepStatus.completed));

      // Step 3: Payment Processing (In Progress)
      expect(steps[2].title, equals('Payment\nProcessing'));
      expect(steps[2].status, equals(PaymentStepStatus.inProgress));
      expect(steps[2].dateOrStatus, equals('In Progress'));

      // Step 4: Amount Credited (Pending)
      expect(steps[3].title, equals('Amount\nCredited'));
      expect(steps[3].status, equals(PaymentStepStatus.pending));
      expect(steps[3].dateOrStatus, equals('Pending'));
    });

    test('Handles repository error with graceful error message', () async {
      final failingRepo = FailingPaymentRepository();
      final errController = PaymentStatusController(
        paymentRepository: failingRepo,
        applicationRepository: applicationRepo,
        applicationId: 'app-error',
      );

      await errController.loadData();

      expect(errController.isLoading, isFalse);
      expect(errController.errorMessage, isNotNull);
      expect(errController.errorMessage, contains('Failed to connect to DBT payment gateway'));

      errController.dispose();
    });
  });

  group('PaymentStatusScreen Widget & Visual Target Fidelity Tests', () {
    late MockPaymentRepository paymentRepo;
    late MockApplicationRepository applicationRepo;

    setUp(() {
      paymentRepo = MockPaymentRepository(latency: Duration.zero);
      applicationRepo = MockApplicationRepository(latency: Duration.zero);
    });

    Widget createTestWidget({
      PaymentStatusController? controller,
      Application? initialApplication,
      String? applicationId,
    }) {
      return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Plus Jakarta Sans',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111827)),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/application-details') {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Application Details Mock')),
            );
          }
          return null;
        },
        home: PaymentStatusScreen(
          controller: controller,
          initialApplication: initialApplication,
          applicationId: applicationId ?? 'app-2026-st-01',
        ),
      );
    }

    testWidgets('Renders all visual components faithfully', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1400 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ctrl = PaymentStatusController(
        paymentRepository: paymentRepo,
        applicationRepository: applicationRepo,
        applicationId: 'app-2026-st-01',
      );
      await ctrl.loadData();

      await tester.pumpWidget(createTestWidget(controller: ctrl));
      await tester.pumpAndSettle();

      // 1. DashboardHeader
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('AS'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);

      // 2. PaymentStatusPageHeader
      expect(find.byType(PaymentStatusPageHeader), findsOneWidget);
      expect(find.text('Payment / DBT Status'), findsOneWidget);
      expect(
        find.text('Track the payment status for your approved application.'),
        findsOneWidget,
      );

      // 3. Application Summary Card
      expect(find.byType(PaymentApplicationSummaryCard), findsOneWidget);
      expect(find.text('Application ID'), findsOneWidget);
      expect(find.text('TS2026ST000123'), findsOneWidget);
      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('Post Matric Scholarship for ST Students'), findsOneWidget);
      expect(find.text('View Application'), findsOneWidget);

      // 4. Payment Progress Stepper
      expect(find.byType(PaymentProgressStepper), findsOneWidget);
      expect(find.text('Payment Progress'), findsOneWidget);
      expect(find.text('Application\nApproved'), findsOneWidget);
      expect(find.text('Sanction\nReleased'), findsOneWidget);
      expect(find.text('Payment\nProcessing'), findsOneWidget);
      expect(find.text('Payment Processing'), findsOneWidget);
      expect(find.text('Amount\nCredited'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);

      // 5. Payment Processing Callout Card
      expect(find.byType(PaymentProcessingCalloutCard), findsOneWidget);
      expect(
        find.text(
          'Your scholarship amount has been sanctioned and is currently being processed for DBT transfer to your bank account.',
        ),
        findsOneWidget,
      );

      // 6. Payment Details Card
      expect(find.byType(PaymentDetailsCard), findsOneWidget);
      expect(find.text('Payment Details'), findsOneWidget);
      expect(find.text('Sanction Order Number'), findsOneWidget);
      expect(find.text('TRI-2026-0009876'), findsOneWidget);
      expect(find.text('Sanction Date'), findsOneWidget);
      expect(find.text('10 Jan 2026'), findsNWidgets(2)); // stepper & details card
      expect(find.text('Sanctioned Amount'), findsOneWidget);
      expect(find.text('₹ 48,000'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Direct Benefit Transfer (DBT)'), findsOneWidget);
      expect(find.text('Bank Account'), findsOneWidget);
      expect(find.text('XXXX XXXX 1234'), findsOneWidget);
      expect(find.text('State Bank of India'), findsOneWidget);
      expect(find.text('Expected Credit Date'), findsOneWidget);
      expect(find.text('Within 7–10 working days'), findsOneWidget);
      expect(find.text('Payment Reference'), findsOneWidget);
      expect(find.text('TRI-PAY-2026-001234'), findsOneWidget);
      expect(find.text('Generated on 10 Jan 2026'), findsOneWidget);

      // 7. Informational Callout Cards
      expect(find.byType(PaymentInfoCalloutCards), findsOneWidget);
      expect(find.text('What happens next?'), findsOneWidget);
      expect(
        find.text(
          'The payment will be credited directly to your bank account through DBT. You will receive an in-app notification once the amount is credited.',
        ),
        findsOneWidget,
      );
      expect(find.text('Important Information'), findsOneWidget);
      expect(
        find.text(
          'Payment timelines may vary based on bank processing and government procedures. Please ensure your bank account is active and linked with Aadhaar.',
        ),
        findsOneWidget,
      );

      // 8. CustomBottomNavBar with Applications tab selected
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
      final navBar = tester.widget<CustomBottomNavBar>(find.byType(CustomBottomNavBar));
      expect(navBar.selectedIndex, equals(2));
    });

    testWidgets('Tapping View Application triggers navigation to application details',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ctrl = PaymentStatusController(
        paymentRepository: paymentRepo,
        applicationRepository: applicationRepo,
        applicationId: 'app-2026-st-01',
      );
      await ctrl.loadData();

      await tester.pumpWidget(createTestWidget(controller: ctrl));
      await tester.pumpAndSettle();

      final viewAppButton = find.text('View Application');
      expect(viewAppButton, findsOneWidget);

      await tester.tap(viewAppButton);
      await tester.pumpAndSettle();

      expect(find.text('Application Details Mock'), findsOneWidget);
    });

    testWidgets('Displays error state with Retry button on failure', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final failingRepo = FailingPaymentRepository();
      final errCtrl = PaymentStatusController(
        paymentRepository: failingRepo,
        applicationRepository: applicationRepo,
        applicationId: 'app-err',
      );

      await tester.pumpWidget(createTestWidget(controller: errCtrl));
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.textContaining('Failed to connect to DBT payment gateway'), findsOneWidget);
    });
  });

  group('PaymentStatusScreen Responsive & Dimension Tests', () {
    late MockPaymentRepository paymentRepo;
    late MockApplicationRepository applicationRepo;

    setUp(() {
      paymentRepo = MockPaymentRepository(latency: Duration.zero);
      applicationRepo = MockApplicationRepository(latency: Duration.zero);
    });

    testWidgets('Zero overflow on Small Phone (360 x 640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final ctrl = PaymentStatusController(
        paymentRepository: paymentRepo,
        applicationRepository: applicationRepo,
        applicationId: 'app-2026-st-01',
      );
      await ctrl.loadData();

      await tester.pumpWidget(
        MaterialApp(
          home: PaymentStatusScreen(controller: ctrl),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final ctrl = PaymentStatusController(
        paymentRepository: paymentRepo,
        applicationRepository: applicationRepo,
        applicationId: 'app-2026-st-01',
      );
      await ctrl.loadData();

      await tester.pumpWidget(
        MaterialApp(
          home: PaymentStatusScreen(controller: ctrl),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final ctrl = PaymentStatusController(
        paymentRepository: paymentRepo,
        applicationRepository: applicationRepo,
        applicationId: 'app-2026-st-01',
      );
      await ctrl.loadData();

      await tester.pumpWidget(
        MaterialApp(
          home: PaymentStatusScreen(controller: ctrl),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
