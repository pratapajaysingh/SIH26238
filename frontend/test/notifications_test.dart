import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/utils/date_formatter.dart';
import 'package:tribalsetu/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/features/notifications/controllers/notifications_controller.dart';
import 'package:tribalsetu/features/notifications/screens/notifications_screen.dart';
import 'package:tribalsetu/features/notifications/widgets/notification_card_item.dart';
import 'package:tribalsetu/features/notifications/widgets/notifications_empty_state.dart';
import 'package:tribalsetu/features/notifications/widgets/notifications_filter_bar.dart';
import 'package:tribalsetu/models/notification_item.dart';
import 'package:tribalsetu/repositories/mock_notification_repository.dart';
import 'package:tribalsetu/repositories/notification_repository.dart';

class FailingNotificationRepository implements NotificationRepository {
  @override
  Future<List<NotificationItem>> getNotifications() async {
    throw Exception('Server unreachable: 500');
  }

  @override
  Future<int> getUnreadCount() async {
    throw Exception('Server unreachable: 500');
  }

  @override
  Future<void> markAsRead(String id) async {
    throw Exception('Failed to update read state: 500');
  }
}

class EmptyNotificationRepository implements NotificationRepository {
  @override
  Future<List<NotificationItem>> getNotifications() async => [];

  @override
  Future<int> getUnreadCount() async => 0;

  @override
  Future<void> markAsRead(String id) async {}
}

void main() {
  group('NotificationsController Unit & State Tests', () {
    late MockNotificationRepository repository;
    late NotificationsController controller;

    setUp(() {
      MockNotificationRepository.reset();
      repository = MockNotificationRepository(latency: Duration.zero);
      controller = NotificationsController(repository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state: not loading, no error, all filter active', () {
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.selectedFilter, equals(NotificationFilter.all));
      expect(controller.allNotifications, isEmpty);
      expect(controller.unreadCount, equals(0));
    });

    test('loadNotifications populates notifications list and calculates unread count', () async {
      await controller.loadNotifications();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.allNotifications.length, equals(7));
      expect(controller.unreadCount, equals(3));
    });

    test('Category filtering functions accurately in-memory', () async {
      await controller.loadNotifications();

      // 1. All Filter (7 items)
      controller.setFilter(NotificationFilter.all);
      expect(controller.filteredNotifications.length, equals(7));

      // 2. Unread Filter (3 items: notif-01, notif-02, notif-03)
      controller.setFilter(NotificationFilter.unread);
      expect(controller.filteredNotifications.length, equals(3));
      expect(controller.filteredNotifications.every((n) => !n.isRead), isTrue);

      // 3. Applications Filter (items with applicationId != null: 5 items)
      controller.setFilter(NotificationFilter.applications);
      expect(controller.filteredNotifications.length, equals(5));
      expect(controller.filteredNotifications.every((n) => n.applicationId != null), isTrue);

      // 4. Payments Filter (payment/sanction/DBT: notif-01, notif-06)
      controller.setFilter(NotificationFilter.payments);
      expect(controller.filteredNotifications.length, equals(2));
      expect(
        controller.filteredNotifications.map((n) => n.id).toList(),
        containsAll(['notif-01', 'notif-06']),
      );

      // 5. System Filter (profile/welcome/system: notif-04, notif-07)
      controller.setFilter(NotificationFilter.system);
      expect(controller.filteredNotifications.length, equals(2));
      expect(
        controller.filteredNotifications.map((n) => n.id).toList(),
        containsAll(['notif-04', 'notif-07']),
      );
    });

    test('markAsRead updates item state and decrements unread count', () async {
      await controller.loadNotifications();
      expect(controller.unreadCount, equals(3));

      await controller.markAsRead('notif-01');

      final updated = controller.allNotifications.firstWhere((n) => n.id == 'notif-01');
      expect(updated.isRead, isTrue);
      expect(controller.unreadCount, equals(2));
    });

    test('markAsRead on already read item does nothing', () async {
      await controller.loadNotifications();
      final readItem = controller.allNotifications.firstWhere((n) => n.id == 'notif-04');
      expect(readItem.isRead, isTrue);

      await controller.markAsRead('notif-04');
      expect(controller.unreadCount, equals(3));
    });

    test('Error handling when repository throws', () async {
      final failingRepo = FailingNotificationRepository();
      final failController = NotificationsController(repository: failingRepo);

      await failController.loadNotifications();

      expect(failController.isLoading, isFalse);
      expect(failController.errorMessage, contains('Failed to load notifications'));

      failController.clearError();
      expect(failController.errorMessage, isNull);

      failController.dispose();
    });
  });

  group('NotificationsScreen Widget & Visual Target Fidelity Tests', () {
    late MockNotificationRepository repository;

    setUp(() {
      MockNotificationRepository.reset();
      repository = MockNotificationRepository(latency: Duration.zero);
    });

    Widget createTestWidget({NotificationsController? customController}) {
      final ctrl = customController ?? NotificationsController(repository: repository);
      if (customController == null) {
        ctrl.loadNotifications();
      }

      return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Plus Jakarta Sans',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111827)),
        ),
        onGenerateRoute: (settings) {
          if (settings.name == '/application-details') {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Text('Application Details: ${settings.arguments}'),
              ),
            );
          }
          if (settings.name == '/dashboard') {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Dashboard')),
            );
          }
          if (settings.name == '/profile') {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('Profile')),
            );
          }
          return null;
        },
        home: NotificationsScreen(controller: ctrl),
      );
    }

    testWidgets('Renders all header, branding, and tribal decoration elements', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. DashboardHeader
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.bySemanticsLabel('Government of India emblem'), findsOneWidget);
      expect(find.bySemanticsLabel('TribalSetu brand'), findsOneWidget);
      expect(find.text('AS'), findsOneWidget);

      // Notification bell present in header
      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);
    });

    testWidgets('Renders Page Title and exact Subtitle faithfully', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(
        find.text('Stay updated on your applications, verifications and payments.'),
        findsOneWidget,
      );
    });

    testWidgets('Renders NotificationsFilterBar with all 5 capsule tabs', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsFilterBar), findsOneWidget);
      expect(find.descendant(of: find.byType(NotificationsFilterBar), matching: find.text('All')), findsOneWidget);
      expect(find.descendant(of: find.byType(NotificationsFilterBar), matching: find.text('Unread')), findsOneWidget);
      expect(find.descendant(of: find.byType(NotificationsFilterBar), matching: find.text('Applications')), findsOneWidget);
      expect(find.descendant(of: find.byType(NotificationsFilterBar), matching: find.text('Payments')), findsOneWidget);
      expect(find.descendant(of: find.byType(NotificationsFilterBar), matching: find.text('System')), findsOneWidget);
    });

    testWidgets('Renders all 7 notification cards with exact reference content and timestamps', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1200 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(NotificationCardItem), findsNWidgets(7));

      // Titles
      expect(find.text('Payment Initiated'), findsOneWidget);
      expect(find.text('Document Verified'), findsOneWidget);
      expect(find.text('Application Status Updated'), findsOneWidget);
      expect(find.text('Profile Updated'), findsOneWidget);
      expect(find.text('Document Action Required'), findsOneWidget);
      expect(find.text('Sanction Order Released'), findsOneWidget);
      expect(find.text('Welcome to TribalSetu'), findsOneWidget);

      // Messages
      expect(find.textContaining('Your scholarship amount of ₹48,000 has been initiated'), findsOneWidget);
      expect(find.textContaining('Your Aadhaar Card has been successfully verified'), findsOneWidget);
      expect(find.textContaining('Your application TS2026ST000123 is now under verification'), findsOneWidget);
      expect(find.textContaining('Your profile information has been successfully updated'), findsOneWidget);
      expect(find.textContaining('Your Income Certificate could not be verified'), findsOneWidget);
      expect(find.textContaining('Your application has been sanctioned'), findsOneWidget);
      expect(find.textContaining('Your account has been successfully created'), findsOneWidget);

      // Timestamps formatted via DateFormatter
      expect(find.text(DateFormatter.formatDateTime(DateTime(2025, 12, 12, 16, 30))), findsOneWidget);
      expect(find.text(DateFormatter.formatDateTime(DateTime(2025, 12, 11, 10, 15))), findsOneWidget);
      expect(find.text(DateFormatter.formatDateTime(DateTime(2025, 12, 10, 14, 20))), findsOneWidget);
    });

    testWidgets('Tapping Unread filter tab filters to only unread cards', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Unread tab
      await tester.tap(find.text('Unread'));
      await tester.pumpAndSettle();

      // Now 3 cards should be displayed
      expect(find.byType(NotificationCardItem), findsNWidgets(3));
      expect(find.text('Payment Initiated'), findsOneWidget);
      expect(find.text('Document Verified'), findsOneWidget);
      expect(find.text('Application Status Updated'), findsOneWidget);
      expect(find.text('Profile Updated'), findsNothing);

      // Tap All tab to return
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationCardItem), findsNWidgets(7));
    });

    testWidgets('Tapping an unread card marks it as read and navigates if application-linked', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap 'Application Status Updated' card (linked to 'app-2026-st-01')
      await tester.tap(find.text('Application Status Updated'));
      await tester.pumpAndSettle();

      // Navigated to /application-details with applicationId
      expect(find.text('Application Details: app-2026-st-01'), findsOneWidget);
    });

    testWidgets('Renders contextual empty state when filter has zero results', (tester) async {
      final emptyCtrl = NotificationsController(repository: EmptyNotificationRepository());
      await emptyCtrl.loadNotifications();

      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(customController: emptyCtrl));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsEmptyState), findsOneWidget);
      expect(find.text('No Notifications Yet'), findsOneWidget);

      emptyCtrl.dispose();
    });

    testWidgets('Global bottom navigation renders with no active tab selected (selectedIndex: -1)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final navBar = tester.widget<CustomBottomNavBar>(find.byType(CustomBottomNavBar));
      expect(navBar.selectedIndex, equals(-1));
      expect(find.descendant(of: find.byType(CustomBottomNavBar), matching: find.text('JAGO')), findsOneWidget);
      expect(find.descendant(of: find.byType(CustomBottomNavBar), matching: find.text('Home')), findsOneWidget);
      expect(find.descendant(of: find.byType(CustomBottomNavBar), matching: find.text('Scholarships')), findsOneWidget);
      expect(find.descendant(of: find.byType(CustomBottomNavBar), matching: find.text('Applications')), findsOneWidget);
      expect(find.descendant(of: find.byType(CustomBottomNavBar), matching: find.text('Profile')), findsOneWidget);
    });
  });

  group('NotificationsScreen Responsive & Dimension Tests (Zero Overflow Verification)', () {
    late MockNotificationRepository repository;

    setUp(() {
      MockNotificationRepository.reset();
      repository = MockNotificationRepository(latency: Duration.zero);
    });

    Widget createTestWidget() {
      final ctrl = NotificationsController(repository: repository);
      ctrl.loadNotifications();

      return MaterialApp(
        theme: ThemeData(
          fontFamily: 'Plus Jakarta Sans',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111827)),
        ),
        home: NotificationsScreen(controller: ctrl),
      );
    }

    testWidgets('Zero overflow on Small Phone (360 x 640)', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(NotificationCardItem), findsWidgets);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(NotificationCardItem), findsWidgets);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768 * 2, 1024 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(NotificationCardItem), findsWidgets);
    });
  });
}
