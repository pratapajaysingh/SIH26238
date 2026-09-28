import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/features/auth/controllers/auth_controller.dart';
import 'package:tribalsetu/features/dashboard/controllers/home_controller.dart';
import 'package:tribalsetu/features/dashboard/dashboard_screen.dart';
import 'package:tribalsetu/features/dashboard/widgets/application_status_tracker.dart';
import 'package:tribalsetu/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/features/dashboard/widgets/hero_scholarship_banner.dart';
import 'package:tribalsetu/features/dashboard/widgets/quick_actions_section.dart';
import 'package:tribalsetu/features/dashboard/widgets/recommended_scholarship_card.dart';
import 'package:tribalsetu/features/dashboard/widgets/search_bar_widget.dart';
import 'package:tribalsetu/features/dashboard/widgets/student_greeting_section.dart';
import 'package:tribalsetu/repositories/mock_application_repository.dart';
import 'package:tribalsetu/repositories/mock_auth_repository.dart';
import 'package:tribalsetu/repositories/mock_notification_repository.dart';
import 'package:tribalsetu/repositories/mock_scholarship_repository.dart';
import 'package:tribalsetu/repositories/mock_student_repository.dart';

void main() {
  group('HomeController Unit Tests', () {
    late HomeController controller;
    late MockStudentRepository studentRepo;
    late MockScholarshipRepository scholarshipRepo;
    late MockApplicationRepository applicationRepo;
    late MockNotificationRepository notificationRepo;

    setUp(() {
      studentRepo = MockStudentRepository(latency: Duration.zero);
      scholarshipRepo = MockScholarshipRepository(latency: Duration.zero);
      applicationRepo = MockApplicationRepository(latency: Duration.zero);
      notificationRepo = MockNotificationRepository(latency: Duration.zero);

      controller = HomeController(
        studentRepository: studentRepo,
        scholarshipRepository: scholarshipRepo,
        applicationRepository: applicationRepo,
        notificationRepository: notificationRepo,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Loads complete dashboard data correctly', () async {
      expect(controller.isLoading, isTrue);

      await controller.loadDashboard();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);

      // Verify student summary
      expect(controller.studentSummary, isNotNull);
      expect(controller.studentSummary!.name, equals('Aarav Singh'));
      expect(controller.studentSummary!.initials, equals('AS'));
      expect(controller.studentSummary!.studentId, equals('TS2024S10023'));

      // Verify recommended scholarship
      expect(controller.recommendedScholarship, isNotNull);
      expect(controller.recommendedScholarship!.code, equals('POST_MATRIC'));
      expect(controller.recommendedScholarship!.name, contains('Post Matric Scholarship'));

      // Verify application and timeline
      expect(controller.activeApplication, isNotNull);
      expect(controller.activeApplication!.applicationNumber, equals('TS2024S10023'));
      expect(controller.timelineEvents.length, equals(4));
      expect(controller.timelineEvents[0].stage, equals('Applied'));
      expect(controller.timelineEvents[1].stage, equals('Under Review'));
      expect(controller.timelineEvents[2].stage, equals('Verification'));
      expect(controller.timelineEvents[3].stage, equals('Payment'));

      // Verify notification count
      expect(controller.unreadNotificationsCount, greaterThanOrEqualTo(1));
    });
  });

  group('DashboardScreen Widget & Fidelity Tests', () {
    late AuthController authController;
    late HomeController homeController;

    setUp(() {
      authController = AuthController(authRepository: MockAuthRepository());
      homeController = HomeController(
        studentRepository: MockStudentRepository(latency: Duration.zero),
        scholarshipRepository: MockScholarshipRepository(latency: Duration.zero),
        applicationRepository: MockApplicationRepository(latency: Duration.zero),
        notificationRepository: MockNotificationRepository(latency: Duration.zero),
      );
    });

    tearDown(() {
      authController.dispose();
      homeController.dispose();
    });

    Widget createTestWidget({Size physicalSize = const Size(390, 844)}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: physicalSize,
            padding: const EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: DashboardScreen(
            authController: authController,
            homeController: homeController,
          ),
        ),
      );
    }

    testWidgets('Renders all required visual components faithfully', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // 1. Header components
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('AS'), findsOneWidget);

      // 2. Greeting & Student ID
      expect(find.byType(StudentGreetingSection), findsOneWidget);
      expect(find.text('Aarav Singh'), findsOneWidget);
      expect(find.text('TS2024S10023'), findsOneWidget);
      expect(find.text('Keep going! Your dreams matter.'), findsOneWidget);

      // 3. Search Bar
      expect(find.byType(SearchBarWidget), findsOneWidget);
      expect(find.text('Search for scholarships, schemes, or help...'), findsOneWidget);

      // 4. Hero Banner
      expect(find.byType(HeroScholarshipBanner), findsOneWidget);
      expect(find.text('Explore Schemes'), findsOneWidget);

      // 5. Quick Actions
      expect(find.byType(QuickActionsSection), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Find\nScholarships'), findsOneWidget);
      expect(find.text('My\nApplications'), findsOneWidget);
      expect(find.text('Document\nLocker'), findsOneWidget);
      expect(find.text('Payment\nStatus'), findsOneWidget);
      expect(find.text('Ask JAGO'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);

      // 6. Recommended for You
      expect(find.byType(RecommendedScholarshipCard), findsOneWidget);
      expect(find.text('Recommended for You'), findsOneWidget);
      expect(find.text('Post Matric Scholarship for ST Students'), findsOneWidget);
      expect(find.text('Most Relevant'), findsOneWidget);

      // 7. Application Status
      expect(find.byType(ApplicationStatusTracker), findsOneWidget);
      expect(find.text('Application Status'), findsOneWidget);
      expect(find.text('Applied'), findsOneWidget);
      expect(find.text('Under Review'), findsOneWidget);
      expect(find.text('Verification'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);

      // 8. Custom Bottom Nav Bar with elevated JAGO button
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Scholarships'), findsOneWidget);
      expect(find.text('JAGO'), findsOneWidget);
      expect(find.text('Applications'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Responsive test: Zero overflow on small phone (360 x 640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(physicalSize: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Aarav Singh'), findsOneWidget);
    });

    testWidgets('Responsive test: Zero overflow on standard phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(physicalSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Responsive test: Zero overflow on large phone (430 x 932)', (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(physicalSize: const Size(430, 932)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
