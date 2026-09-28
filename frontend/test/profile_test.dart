import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/constants/asset_constants.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/features/profile/controllers/profile_controller.dart';
import 'package:tribalsetu/features/profile/screens/my_profile_screen.dart';
import 'package:tribalsetu/features/profile/widgets/profile_document_section.dart';
import 'package:tribalsetu/features/profile/widgets/profile_hero_card.dart';
import 'package:tribalsetu/features/profile/widgets/profile_info_section_card.dart';
import 'package:tribalsetu/features/profile/widgets/profile_page_header.dart';
import 'package:tribalsetu/repositories/mock_document_repository.dart';
import 'package:tribalsetu/repositories/mock_profile_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileController Unit & State Tests', () {
    late MockProfileRepository profileRepository;
    late MockDocumentRepository documentRepository;
    late ProfileController controller;

    setUp(() {
      profileRepository = MockProfileRepository(latency: Duration.zero);
      documentRepository = MockDocumentRepository(latency: Duration.zero);
      controller = ProfileController(
        profileRepository: profileRepository,
        documentRepository: documentRepository,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state: not loading, no error, null profile, empty documents', () {
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.profile, isNull);
      expect(controller.documents, isEmpty);
    });

    test('loadProfile() populates student profile and documents matching reference', () async {
      await controller.loadProfile();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.profile, isNotNull);

      final profile = controller.profile!;
      expect(profile.id, equals('TS2024S10023'));
      expect(profile.fullName, equals('Aarav Singh'));
      expect(profile.studentTypeDisplay, equals('ST Student'));
      expect(profile.categoryDisplay, equals('Scheduled Tribe (ST)'));
      expect(profile.dateOfBirthFormatted, equals('14 Mar 2006'));
      expect(profile.gender, equals('Male'));
      expect(profile.mobile, equals('+91 98765 43210'));
      expect(profile.email, equals('aaravsingh@example.com'));
      expect(profile.formattedAddress, contains('Village - Karanpur, Block - Bishrampur'));
      expect(profile.formattedAddress, contains('District - Surguja, Chhattisgarh - 497226'));
      expect(profile.course, equals('B.Sc. (1st Year)'));
      expect(profile.institutionName, equals('Government College, Ambikapur'));
      expect(profile.academicYear, equals('2024 - 2025'));
      expect(profile.isVerified, isTrue);

      expect(controller.documents.length, equals(6));
      expect(controller.documents.any((d) => d.docName == 'Aadhaar Card'), isTrue);
      expect(controller.documents.any((d) => d.docName == 'Caste Certificate'), isTrue);
      expect(controller.documents.any((d) => d.docName == 'Income Certificate'), isTrue);
    });
  });

  group('MyProfileScreen Widget & Visual Fidelity Tests', () {
    late MockProfileRepository profileRepository;
    late MockDocumentRepository documentRepository;
    late ProfileController controller;

    setUp(() {
      profileRepository = MockProfileRepository(latency: Duration.zero);
      documentRepository = MockDocumentRepository(latency: Duration.zero);
      controller = ProfileController(
        profileRepository: profileRepository,
        documentRepository: documentRepository,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MyProfileScreen(
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
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == AssetConstants.topTribalPattern,
        ),
        findsOneWidget,
      );

      // 2. DashboardHeader elements
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('AS'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);

      // 3. ProfilePageHeader
      expect(find.byType(ProfilePageHeader), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
      expect(
        find.text('View and manage your personal details, documents\nand preferences.'),
        findsOneWidget,
      );

      // 4. Bottom Navigation Bar with Profile Active
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Scholarships'), findsOneWidget);
      expect(find.text('JAGO'), findsOneWidget);
      expect(find.text('Applications'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Renders Profile Hero Card with avatar, details, and Edit Profile button', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1200 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ProfileHeroCard), findsOneWidget);
      expect(find.text('Aarav Singh'), findsWidgets);
      expect(find.text('ST Student'), findsOneWidget);
      expect(find.text('Student ID: TS2024S10023'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    });

    testWidgets('Renders Personal, Contact, and Academic Information sections', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1600 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ProfileInfoSectionCard), findsNWidgets(3));

      // Personal Information
      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('14 Mar 2006'), findsOneWidget);
      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Scheduled Tribe (ST)'), findsOneWidget);

      // Contact Information
      expect(find.text('Contact Information'), findsOneWidget);
      expect(find.text('Mobile Number'), findsOneWidget);
      expect(find.text('+91 98765 43210'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('aaravsingh@example.com'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);

      // Academic Information
      expect(find.text('Academic Information'), findsOneWidget);
      expect(find.text('Current Education Level'), findsOneWidget);
      expect(find.text('B.Sc. (1st Year)'), findsOneWidget);
      expect(find.text('Institute Name'), findsOneWidget);
      expect(find.text('Government College, Ambikapur'), findsOneWidget);
      expect(find.text('Academic Year'), findsOneWidget);
      expect(find.text('2024 - 2025'), findsOneWidget);
    });

    testWidgets('Renders Document Management section with compact horizontal cards', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 1600 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ProfileDocumentSection), findsOneWidget);
      expect(find.text('Document Management'), findsOneWidget);
      expect(find.text('View All >'), findsOneWidget);

      expect(find.text('Aadhaar Card'), findsOneWidget);
      expect(find.text('Caste Certificate'), findsOneWidget);
      expect(find.text('Income Certificate'), findsOneWidget);
      expect(find.text('Under Review'), findsOneWidget);
    });
  });

  group('MyProfileScreen Responsive & Dimension Tests', () {
    late MockProfileRepository profileRepository;
    late MockDocumentRepository documentRepository;
    late ProfileController controller;

    setUp(() {
      profileRepository = MockProfileRepository(latency: Duration.zero);
      documentRepository = MockDocumentRepository(latency: Duration.zero);
      controller = ProfileController(
        profileRepository: profileRepository,
        documentRepository: documentRepository,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MyProfileScreen(
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

      expect(find.text('My Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768 * 2, 1024 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('My Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
