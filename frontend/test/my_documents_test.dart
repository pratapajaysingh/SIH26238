import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tribalsetu/core/enums/document_status.dart';
import 'package:tribalsetu/features/dashboard/widgets/custom_bottom_nav_bar.dart';
import 'package:tribalsetu/features/dashboard/widgets/dashboard_header.dart';
import 'package:tribalsetu/features/documents/controllers/my_documents_controller.dart';
import 'package:tribalsetu/features/documents/screens/my_documents_screen.dart';
import 'package:tribalsetu/features/documents/widgets/document_action_cards.dart';
import 'package:tribalsetu/features/documents/widgets/document_category_tabs.dart';
import 'package:tribalsetu/features/documents/widgets/document_important_info_card.dart';
import 'package:tribalsetu/features/documents/widgets/document_wallet_card_item.dart';
import 'package:tribalsetu/features/documents/widgets/my_documents_page_header.dart';
import 'package:tribalsetu/models/document.dart';
import 'package:tribalsetu/repositories/mock_document_repository.dart';

void main() {
  group('MyDocumentsController Unit Tests', () {
    late MockDocumentRepository mockRepo;
    late MyDocumentsController controller;

    setUp(() {
      mockRepo = MockDocumentRepository(latency: Duration.zero);
      controller = MyDocumentsController(documentRepository: mockRepo);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state: not loading, no error, empty documents, default category', () {
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.documents, isEmpty);
      expect(controller.selectedCategory, equals('All Documents'));
      expect(controller.filteredDocuments, isEmpty);
    });

    test('loadDocuments() loads 6 canonical reference documents', () async {
      await controller.loadDocuments();

      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.documents.length, equals(6));
      expect(controller.filteredDocuments.length, equals(6));

      expect(controller.documents[0].docName, equals('Aadhaar Card'));
      expect(controller.documents[0].status, equals(DocumentStatus.verified));
      expect(controller.documents[0].categoryDisplay, equals('Identity'));

      expect(controller.documents[1].docName, equals('10th Mark Sheet'));
      expect(controller.documents[1].status, equals(DocumentStatus.verified));
      expect(controller.documents[1].categoryDisplay, equals('Academic'));

      expect(controller.documents[2].docName, equals('12th Mark Sheet'));
      expect(controller.documents[2].status, equals(DocumentStatus.verified));
      expect(controller.documents[2].categoryDisplay, equals('Academic'));

      expect(controller.documents[3].docName, equals('Income Certificate'));
      expect(controller.documents[3].status, equals(DocumentStatus.pending));
      expect(controller.documents[3].categoryDisplay, equals('Income'));

      expect(controller.documents[4].docName, equals('Caste Certificate'));
      expect(controller.documents[4].status, equals(DocumentStatus.verified));
      expect(controller.documents[4].categoryDisplay, equals('Caste'));

      expect(controller.documents[5].docName, equals('Domicile Certificate'));
      expect(controller.documents[5].status, equals(DocumentStatus.rejected));
      expect(controller.documents[5].categoryDisplay, equals('Other'));
    });

    test('selectCategory filters documents correctly across all categories', () async {
      await controller.loadDocuments();

      // Identity -> Aadhaar Card only
      controller.selectCategory('Identity');
      expect(controller.selectedCategory, equals('Identity'));
      expect(controller.filteredDocuments.length, equals(1));
      expect(controller.filteredDocuments[0].docName, equals('Aadhaar Card'));

      // Academic -> 10th and 12th mark sheets
      controller.selectCategory('Academic');
      expect(controller.selectedCategory, equals('Academic'));
      expect(controller.filteredDocuments.length, equals(2));
      expect(controller.filteredDocuments[0].docName, equals('10th Mark Sheet'));
      expect(controller.filteredDocuments[1].docName, equals('12th Mark Sheet'));

      // Income -> Income Certificate
      controller.selectCategory('Income');
      expect(controller.selectedCategory, equals('Income'));
      expect(controller.filteredDocuments.length, equals(1));
      expect(controller.filteredDocuments[0].docName, equals('Income Certificate'));

      // Caste -> Caste Certificate
      controller.selectCategory('Caste');
      expect(controller.selectedCategory, equals('Caste'));
      expect(controller.filteredDocuments.length, equals(1));
      expect(controller.filteredDocuments[0].docName, equals('Caste Certificate'));

      // Other -> Domicile Certificate
      controller.selectCategory('Other');
      expect(controller.selectedCategory, equals('Other'));
      expect(controller.filteredDocuments.length, equals(1));
      expect(controller.filteredDocuments[0].docName, equals('Domicile Certificate'));

      // All Documents -> Returns all 6 documents
      controller.selectCategory('All Documents');
      expect(controller.selectedCategory, equals('All Documents'));
      expect(controller.filteredDocuments.length, equals(6));
    });

    test('fetchFromDigiLocker initiates consent and sets action message', () async {
      final success = await controller.fetchFromDigiLocker();
      expect(success, isTrue);
      expect(controller.isActionLoading, isFalse);
      expect(controller.actionFeedbackMessage, isNotNull);
    });

    test('uploadDocument appends new document and updates list', () async {
      await controller.loadDocuments();
      expect(controller.documents.length, equals(6));

      final success = await controller.uploadDocument(
        docType: 'OTHER',
        docName: 'Transfer Certificate',
        filePath: 'path/to/tc.pdf',
        category: 'Other',
      );

      expect(success, isTrue);
      expect(controller.documents.length, equals(7));
      expect(controller.documents.last.docName, equals('Transfer Certificate'));
      expect(controller.documents.last.status, equals(DocumentStatus.pending));
    });

    test('Error handling in loadDocuments() sets errorMessage', () async {
      final errorRepo = _FailingDocumentRepository();
      final errController = MyDocumentsController(documentRepository: errorRepo);

      await errController.loadDocuments();
      expect(errController.isLoading, isFalse);
      expect(errController.errorMessage, contains('Network timeout'));
      errController.dispose();
    });
  });

  group('MyDocumentsScreen Widget & Visual Fidelity Tests', () {
    late MockDocumentRepository mockRepo;
    late MyDocumentsController controller;

    setUp(() {
      mockRepo = MockDocumentRepository(latency: Duration.zero);
      controller = MyDocumentsController(documentRepository: mockRepo);
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MyDocumentsScreen(
          controller: controller,
          studentInitials: 'AS',
          unreadNotificationsCount: 1,
        ),
      );
    }

    testWidgets('Renders all visual header elements faithfully', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Dashboard Header
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('AS'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_rounded), findsOneWidget);

      // Page Header
      expect(find.byType(MyDocumentsPageHeader), findsOneWidget);
      expect(find.text('My Documents'), findsOneWidget);
      expect(
        find.text('Manage your documents for scholarships and other services.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('Renders top 3 action cards with correct titles and descriptions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DocumentActionCards), findsOneWidget);

      // Card 1
      expect(find.text('Upload Document'), findsOneWidget);
      expect(find.text('Add a document\nfrom your device'), findsOneWidget);

      // Card 2
      expect(find.text('Fetch from DigiLocker'), findsOneWidget);
      expect(find.text('Import documents\ndirectly from DigiLocker'), findsOneWidget);

      // Card 3
      expect(find.text('Supported Formats'), findsOneWidget);
      expect(find.text('PDF, JPG, PNG\n(Max 5 MB each)'), findsOneWidget);
    });

    testWidgets('Renders category filter tabs and filters cards on tab tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DocumentCategoryTabs), findsOneWidget);

      // All category pills present
      expect(find.text('All Documents'), findsOneWidget);
      expect(find.text('Identity'), findsOneWidget);
      expect(find.text('Academic'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Caste'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);

      // Initially shows all 6 document cards
      expect(find.byType(DocumentWalletCardItem), findsNWidgets(6));

      // Tap "Academic" tab
      await tester.tap(find.text('Academic'));
      await tester.pumpAndSettle();

      // Only Academic documents (10th and 12th mark sheets) shown
      expect(find.byType(DocumentWalletCardItem), findsNWidgets(2));
      expect(find.text('10th Mark Sheet'), findsOneWidget);
      expect(find.text('12th Mark Sheet'), findsOneWidget);
      expect(find.text('Aadhaar Card'), findsNothing);

      // Tap "Income" tab
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.byType(DocumentWalletCardItem), findsNWidgets(1));
      expect(find.text('Income Certificate'), findsOneWidget);
    });

    testWidgets('Renders all 6 reference document cards with badges and issue dates', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Document titles
      expect(find.text('Aadhaar Card'), findsOneWidget);
      expect(find.text('10th Mark Sheet'), findsOneWidget);
      expect(find.text('12th Mark Sheet'), findsOneWidget);
      expect(find.text('Income Certificate'), findsOneWidget);
      expect(find.text('Caste Certificate'), findsOneWidget);
      expect(find.text('Domicile Certificate'), findsOneWidget);

      // Status labels
      expect(find.text('Verified'), findsNWidgets(4)); // Aadhaar, 10th, 12th, Caste
      expect(find.text('Pending'), findsOneWidget); // Income
      expect(find.text('Rejected'), findsOneWidget); // Domicile

      // Issue dates
      expect(find.text('Issued on 12 Jan 2020'), findsOneWidget);
      expect(find.text('Issued on 20 May 2018'), findsOneWidget);
      expect(find.text('Issued on 15 May 2020'), findsOneWidget);
      expect(find.text('Issued on 10 Mar 2024'), findsOneWidget);
      expect(find.text('Issued on 05 Feb 2021'), findsOneWidget);
      expect(find.text('Issued on 18 Jun 2023'), findsOneWidget);

      // Sources
      expect(find.text('DigiLocker'), findsNWidgets(4));
      expect(find.text('Uploaded'), findsNWidgets(2));

      // View buttons
      expect(find.text('View'), findsNWidgets(6));
    });

    testWidgets('Renders Important Information callout card faithfully', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(DocumentImportantInfoCard), findsOneWidget);
      expect(find.text('Important Information'), findsOneWidget);
      expect(
        find.text(
          'These documents can be used across multiple scholarship applications. Ensure your documents are valid and clearly readable.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders bottom navigation bar with Profile tab active (Index 3)', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final navBar = tester.widget<CustomBottomNavBar>(find.byType(CustomBottomNavBar));
      expect(navBar.selectedIndex, equals(3));
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Scholarships'), findsOneWidget);
      expect(find.text('Applications'), findsOneWidget);
      expect(find.text('JAGO'), findsOneWidget);
    });
  });

  group('MyDocumentsScreen Responsive & Dimension Tests (Zero Overflow Verification)', () {
    late MockDocumentRepository mockRepo;
    late MyDocumentsController controller;

    setUp(() {
      mockRepo = MockDocumentRepository(latency: Duration.zero);
      controller = MyDocumentsController(documentRepository: mockRepo);
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: MyDocumentsScreen(
          controller: controller,
          studentInitials: 'AS',
          unreadNotificationsCount: 1,
        ),
      );
    }

    testWidgets('Zero overflow on Small Phone (360 x 640)', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(MyDocumentsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Standard Phone (390 x 844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(MyDocumentsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Zero overflow on Tablet (768 x 1024)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(MyDocumentsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

class _FailingDocumentRepository implements MockDocumentRepository {
  @override
  Duration get latency => Duration.zero;

  @override
  List<DocumentItem>? get initialDocuments => null;

  @override
  Future<List<DocumentItem>> getDocuments({String? category}) async {
    throw Exception('Network timeout connecting to documents service');
  }

  @override
  Future<DocumentItem> uploadDocument({
    required String docType,
    required String docName,
    required String filePath,
    String? category,
  }) async {
    throw Exception('Upload failed');
  }

  @override
  Future<Map<String, dynamic>> requestDigiLockerConsent() async {
    throw Exception('Consent failed');
  }
}
