import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/features/scholarships/controllers/scholarships_controller.dart';
import 'package:tribalsetu/features/scholarships/screens/find_scholarships_screen.dart';
import 'package:tribalsetu/features/scholarships/widgets/category_filter_chips.dart';
import 'package:tribalsetu/features/scholarships/widgets/results_sort_bar.dart';
import 'package:tribalsetu/features/scholarships/widgets/scholarship_discovery_card.dart';
import 'package:tribalsetu/features/scholarships/widgets/scholarships_page_header.dart';
import 'package:tribalsetu/features/scholarships/widgets/scholarships_search_bar.dart';
import 'package:tribalsetu/repositories/mock_scholarship_repository.dart';

void main() {
  group('ScholarshipsController Unit Tests', () {
    late ScholarshipsController controller;
    late MockScholarshipRepository repository;

    setUp(() {
      repository = MockScholarshipRepository(latency: Duration.zero);
      controller = ScholarshipsController(scholarshipRepository: repository);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state loads correctly', () async {
      expect(controller.isLoading, isTrue);

      await controller.loadScholarships();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.allScholarships.length, equals(6));
      expect(controller.filteredScholarships.length, equals(6));
      expect(controller.resultCount, equals(6));
      expect(controller.selectedCategory, equals('All'));
      expect(controller.selectedSort, equals('Most Relevant'));
    });

    test('Category filtering works for Post Matric', () async {
      await controller.loadScholarships();

      controller.setCategory('Post Matric');
      expect(controller.selectedCategory, equals('Post Matric'));
      expect(controller.filteredScholarships.length, equals(2));
      expect(controller.filteredScholarships.first.name, contains('Post Matric'));

      // Switch back to All
      controller.setCategory('All');
      expect(controller.filteredScholarships.length, equals(6));
    });

    test('Search filtering searches name, ministry, and description', () async {
      await controller.loadScholarships();

      // Search by name keyword
      controller.setSearchQuery('Fellowship');
      expect(controller.filteredScholarships.length, equals(1));
      expect(controller.filteredScholarships.first.name, contains('Fellowship'));

      // Search by ministry
      controller.setSearchQuery('Social Justice');
      expect(controller.filteredScholarships.length, equals(1));
      expect(controller.filteredScholarships.first.ministry, contains('Social Justice'));

      // Search case insensitive
      controller.setSearchQuery('medical');
      expect(controller.filteredScholarships.length, equals(1));
      expect(controller.filteredScholarships.first.name, contains('Medical'));

      // Empty query restores all
      controller.setSearchQuery('');
      expect(controller.filteredScholarships.length, equals(6));
    });

    test('Sorting by Name (A-Z) reorders schemes alphabetically', () async {
      await controller.loadScholarships();

      controller.setSort('Name (A-Z)');
      expect(controller.selectedSort, equals('Name (A-Z)'));

      final names = controller.filteredScholarships.map((s) => s.name).toList();
      final sortedNames = List<String>.from(names)..sort();
      expect(names, equals(sortedNames));
    });

    test('Sorting by Most Relevant places flagged scheme at top', () async {
      await controller.loadScholarships();

      controller.setSort('Most Relevant');
      expect(controller.filteredScholarships.first.isMostRelevant, isTrue);
      expect(controller.filteredScholarships.first.name, contains('Post Matric'));
    });

    test('Reset filters restores initial category, sort, and query', () async {
      await controller.loadScholarships();

      controller.setCategory('Top Class');
      controller.setSearchQuery('Tech');
      controller.setSort('Deadline');

      controller.resetFilters();

      expect(controller.selectedCategory, equals('All'));
      expect(controller.searchQuery, isEmpty);
      expect(controller.selectedSort, equals('Most Relevant'));
      expect(controller.filteredScholarships.length, equals(6));
    });

    test('Handles no results cleanly', () async {
      await controller.loadScholarships();

      controller.setSearchQuery('NonExistentSchemeXYZ');
      expect(controller.filteredScholarships, isEmpty);
      expect(controller.resultCount, equals(0));
    });
  });

  group('FindScholarshipsScreen Widget & Fidelity Tests', () {
    late ScholarshipsController controller;

    setUp(() {
      controller = ScholarshipsController(
        scholarshipRepository: MockScholarshipRepository(latency: Duration.zero),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget({Size physicalSize = const Size(390, 844)}) {
      return MaterialApp(
        routes: {
          '/dashboard': (_) => const Scaffold(body: Text('Dashboard Mock')),
        },
        home: MediaQuery(
          data: MediaQueryData(
            size: physicalSize,
            padding: const EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: FindScholarshipsScreen(
            controller: controller,
            studentInitials: 'AS',
            unreadNotificationsCount: 1,
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

      // 1. Dashboard Header
      expect(find.byType(DashboardHeader), findsOneWidget);

      // 2. Page Header with Back arrow, title, and "My Filters"
      expect(find.byType(ScholarshipsPageHeader), findsOneWidget);
      expect(find.text('Find Scholarships'), findsOneWidget);
      expect(find.textContaining('Discover schemes designed for tribal students'), findsOneWidget);
      expect(find.text('My Filters'), findsOneWidget);

      // 3. Search Bar
      expect(find.byType(ScholarshipsSearchBar), findsOneWidget);
      expect(find.text('Search scholarships, schemes, or keywords...'), findsOneWidget);

      // 4. Category Filter Chips
      expect(find.byType(CategoryFilterChips), findsOneWidget);
      expect(find.descendant(of: find.byType(CategoryFilterChips), matching: find.text('All')), findsOneWidget);
      expect(find.descendant(of: find.byType(CategoryFilterChips), matching: find.text('Pre Matric')), findsOneWidget);

      // 5. Result count & Sort Bar
      expect(find.byType(ResultsSortBar), findsOneWidget);
      expect(find.text('6 Scholarships Found'), findsOneWidget);
      expect(find.descendant(of: find.byType(ResultsSortBar), matching: find.text('Most Relevant')), findsOneWidget);

      // 6. Scholarship Discovery Cards
      expect(find.byType(ScholarshipDiscoveryCard), findsNWidgets(6));
      expect(find.text('Post Matric Scholarship for ST Students'), findsOneWidget);
      expect(find.text('Top Class Education Scheme for ST Students'), findsOneWidget);
      expect(find.text('National Fellowship for ST Students'), findsOneWidget);

      // 7. Status Badges and Benefit amounts
      expect(find.text('Ongoing'), findsWidgets);
      expect(find.text('Closing Soon'), findsOneWidget);
      expect(find.text('Upto ₹48,000'), findsOneWidget);

      // 8. Fixed Bottom Navigation Bar
      expect(find.byType(CustomBottomNavBar), findsOneWidget);
    });

    testWidgets('Tapping category chip filters scholarship cards', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(ScholarshipDiscoveryCard), findsNWidgets(6));

      // Tap 'Post Matric' chip specifically in CategoryFilterChips
      final postMatricChip = find.descendant(
        of: find.byType(CategoryFilterChips),
        matching: find.text('Post Matric'),
      );
      await tester.tap(postMatricChip);
      await tester.pumpAndSettle();

      expect(find.text('2 Scholarships Found'), findsOneWidget);
      expect(find.byType(ScholarshipDiscoveryCard), findsNWidgets(2));
      expect(find.text('Post Matric Scholarship for ST Students'), findsOneWidget);

      // Tap 'All' chip
      final allChip = find.descendant(
        of: find.byType(CategoryFilterChips),
        matching: find.text('All'),
      );
      await tester.tap(allChip);
      await tester.pumpAndSettle();

      expect(find.text('6 Scholarships Found'), findsOneWidget);
      expect(find.byType(ScholarshipDiscoveryCard), findsNWidgets(6));
    });

    testWidgets('Searching filters list and typing shows clear button', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Fellowship');
      await tester.pumpAndSettle();

      expect(find.text('1 Scholarships Found'), findsOneWidget);
      expect(find.text('National Fellowship for ST Students'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('6 Scholarships Found'), findsOneWidget);
      expect(find.byType(ScholarshipDiscoveryCard), findsNWidgets(6));
    });

    testWidgets('Shows empty state when query returns no results', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'UnknownScheme12345');
      await tester.pumpAndSettle();

      expect(find.text('0 Scholarships Found'), findsOneWidget);
      expect(find.text('No scholarships found'), findsOneWidget);
      expect(find.text('Try changing your search keywords or filter category.'), findsOneWidget);
      expect(find.byType(ScholarshipDiscoveryCard), findsNothing);
    });

    testWidgets('Tapping "My Filters" opens filter bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Filters'));
      await tester.pumpAndSettle();

      expect(find.text('Filter Schemes'), findsOneWidget);
      expect(find.text('Apply Filters'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });
  });

  group('FindScholarshipsScreen Responsive & Dimension Tests', () {
    Widget buildResponsiveTest({required Size size}) {
      final controller = ScholarshipsController(
        scholarshipRepository: MockScholarshipRepository(latency: Duration.zero),
      );
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: const EdgeInsets.only(top: 44, bottom: 34),
          ),
          child: FindScholarshipsScreen(
            controller: controller,
            studentInitials: 'AS',
            unreadNotificationsCount: 1,
          ),
        ),
      );
    }

    testWidgets('Zero overflow on Small Phone (360 x 640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildResponsiveTest(size: const Size(360, 640)));
      await tester.pumpAndSettle();

      expect(find.byType(FindScholarshipsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildResponsiveTest(size: const Size(390, 844)));
      await tester.pumpAndSettle();

      expect(find.byType(FindScholarshipsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildResponsiveTest(size: const Size(768, 1024)));
      await tester.pumpAndSettle();

      expect(find.byType(FindScholarshipsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
