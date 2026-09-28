import 'package:flutter/foundation.dart';
import '../../../models/document.dart';
import '../../../models/student_profile.dart';
import '../../../repositories/document_repository.dart';
import '../../../repositories/profile_repository.dart';

/// ProfileController manages state and data flow for the "My Profile" screen.
/// Follows Clean Architecture: UI -> Controller -> Repositories.
class ProfileController extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final DocumentRepository _documentRepository;

  ProfileController({
    required ProfileRepository profileRepository,
    required DocumentRepository documentRepository,
  })  : _profileRepository = profileRepository,
        _documentRepository = documentRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StudentProfile? _profile;
  StudentProfile? get profile => _profile;

  List<DocumentItem> _documents = [];
  List<DocumentItem> get documents => List.unmodifiable(_documents);

  /// Loads student profile and documents from repositories.
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _profileRepository.getProfile(),
        _documentRepository.getDocuments(),
      ]);

      _profile = results[0] as StudentProfile;
      _documents = results[1] as List<DocumentItem>;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load profile details. Please try again.';
      notifyListeners();
    }
  }

  /// Refreshes profile data.
  Future<void> refresh() => loadProfile();
}
