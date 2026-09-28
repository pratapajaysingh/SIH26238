import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/constants/asset_constants.dart';
import 'package:tribalsetu/features/applications/controllers/applications_controller.dart';
import 'package:tribalsetu/features/applications/screens/my_applications_screen.dart';
import 'package:tribalsetu/features/applications/widgets/application_card_item.dart';
import 'package:tribalsetu/features/applications/widgets/applications_filter_bar.dart';
import 'package:tribalsetu/features/applications/widgets/applications_page_header.dart';
import 'package:tribalsetu/repositories/mock_application_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApplicationsController Unit & State Tests', () {
    late MockApplicationRepository repository;
    late ApplicationsController controller;

    setUp(() {
      repository = MockApplicationRepository(latency: Duration.zero);
      controller = ApplicationsController(applicationRepository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state: not loading, no error, All filter selected', () {
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.selectedFilter, equals(ApplicationsFilter.all));
      expect(controller.allApplications, isEmpty);
    });

    test('loadApplications() populates all 5 reference applications with timelines', () async {
      await controller.loadApplications();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.allApplications.length, equals(5));

      // Verify Card 1: Post Matric
      final card1 = controller.allApplications[0];
      expect(card1.applicationNumber, equals('TS2024PMS10023'));
      expect(card1.displayStatus, equals('Under Review'));
      expect(card1.timeline, isNotNull);
      expect(card1.timeline!.length, equals(4));

      // Verify Card 2: Top Class
      final card2 = controller.allApplications[1];
      expect(card2.applicationNumber, equals('TS2024TCS00456'));
      expect(card2.displayStatus, equals('In Progress'));

      // Verify Card 3: National Fellowship
      final card3 = controller.allApplications[2];
      expect(card3.applicationNumber, equals('TS2024NF07890'));
      expect(card3.displayStatus, equals('Documents Required'));

      // Verify Card 4: Pre Matric
      final card4 = controller.allApplications[3];
      expect(card4.applicationNumber, equals('TS2023PRE11223'));
      expect(card4.displayStatus, equals('Rejected'));

      // Verify Card 5: National Overseas
      final card5 = controller.allApplications[4];
      expect(card5.applicationNumber, equals('TS2023NOS55678'));
      expect(card5.displayStatus, equals('Completed'));
    });

    test('Filter switching filters applications correctly', () async {
      await controller.loadApplications();

      // Filter: In Progress (submitted + draft + deficiency)
      controller.setFilter(ApplicationsFilter.inProgress);
      expect(controller.filteredApplications.length, equals(2));
      expect(
        controller.filteredApplications.map((a) => a.applicationNumber),
        containsAll(['TS2024TCS00456', 'TS2024NF07890']),
      );

      // Filter: Under Review (inVerification)
      controller.setFilter(ApplicationsFilter.underReview);
      expect(controller.filteredApplications.length, equals(1));
      expect(controller.filteredApplications.first.applicationNumber, equals('TS2024PMS10023'));

      // Filter: Completed (completed + sanctioned)
      controller.setFilter(ApplicationsFilter.completed);
      expect(controller.filteredApplications.length, equals(1));
      expect(controller.filteredApplications.first.applicationNumber, equals('TS2023NOS55678'));

      // Filter: All
      controller.setFilter(ApplicationsFilter.all);
      expect(controller.filteredApplications.length, equals(5));
    });
  });

  group('MyApplicationsScreen Widget & Visual Fidelity Tests', () {
    late MockApplicationRepository repository;
    late ApplicationsController controller;

    setUp(() {
      repository = MockApplicationRepository(latency: Duration.zero);
      controller = ApplicationsController(applicationRepository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MyApplicationsScreen(
          controller: controller,
          studentInitials: 'AS',
          unreadNotificationsCount: 1,
        ),
      );
    }

    testWidgets('Renders all required visual header elements faithfully', (tester) async {
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

      // 2. DashboardHeader elements
      expect(find.text('AS'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);

      // 3. ApplicationsPageHeader
      expect(find.byType(ApplicationsPageHeader), findsOneWidget);
      expect(find.text('My Applications'), findsOneWidget);
      expect(find.text('Track and manage all your scholarship applications in one place.'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // 4. ApplicationsFilterBar
      expect(find.byType(ApplicationsFilterBar), findsOneWidget);
      expect(find.descendant(of: find.byType(ApplicationsFilterBar), matching: find.text('All')), findsOneWidget);
      expect(find.descendant(of: find.byType(ApplicationsFilterBar), matching: find.text('In Progress')), findsOneWidget);
      expect(find.descendant(of: find.byType(ApplicationsFilterBar), matching: find.text('Under Review')), findsOneWidget);
      expect(find.descendant(of: find.byType(ApplicationsFilterBar), matching: find.text('Completed')), findsOneWidget);

      // 5. Bottom Navigation Bar with Applications Active
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Scholarships'), findsWidgets);
      expect(find.text('JAGO'), findsOneWidget);
      expect(find.text('Applications'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Renders all 5 application cards with IDs, badges, and milestones', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1600 * 2); // Sufficient height to display all cards
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardItem), findsNWidgets(5));

      // Card 1
      expect(find.text('Post Matric Scholarship for ST Students'), findsOneWidget);
      expect(find.text('Application ID: TS2024PMS10023'), findsOneWidget);
      expect(find.text('Applied on 12 Sep 2024'), findsOneWidget);

      // Card 2
      expect(find.text('Top Class Education Scheme for ST Students'), findsOneWidget);
      expect(find.text('Application ID: TS2024TCS00456'), findsOneWidget);
      expect(find.text('Applied on 03 Aug 2024'), findsOneWidget);

      // Card 3
      expect(find.text('National Fellowship for ST Students'), findsOneWidget);
      expect(find.text('Application ID: TS2024NF07890'), findsOneWidget);
      expect(find.text('Applied on 21 Jun 2024'), findsOneWidget);
      expect(find.text('Documents Required'), findsOneWidget);

      // Card 4
      expect(find.text('Pre Matric Scholarship for ST Students'), findsOneWidget);
      expect(find.text('Application ID: TS2023PRE11223'), findsOneWidget);
      expect(find.text('Applied on 10 Jan 2024'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);

      // Card 5
      expect(find.text('National Overseas Scholarship for ST Students'), findsOneWidget);
      expect(find.text('Application ID: TS2023NOS55678'), findsOneWidget);
      expect(find.text('Applied on 15 Nov 2023'), findsOneWidget);
    });

    testWidgets('Tapping filter bar tabs filters applications interactively', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardItem), findsNWidgets(5));

      // Tap "In Progress" filter tab
      await tester.tap(find.descendant(of: find.byType(ApplicationsFilterBar), matching: find.text('In Progress')));
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardItem), findsNWidgets(2));
      expect(find.text('Top Class Education Scheme for ST Students'), findsOneWidget);
      expect(find.text('National Fellowship for ST Students'), findsOneWidget);
      expect(find.text('Post Matric Scholarship for ST Students'), findsNothing);

      // Tap "All" to restore
      await tester.tap(find.descendant(of: find.byType(ApplicationsFilterBar), matching: find.text('All')));
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationCardItem), findsNWidgets(5));
    });
  });

  group('MyApplicationsScreen Responsive & Dimension Tests', () {
    late MockApplicationRepository repository;
    late ApplicationsController controller;

    setUp(() {
      repository = MockApplicationRepository(latency: Duration.zero);
      controller = ApplicationsController(applicationRepository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MyApplicationsScreen(
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

      expect(find.text('My Applications'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Applications'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768 * 2, 1024 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Applications'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
