import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';

/// Language Service
/// Handles language preference storage and retrieval
class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();

  factory LanguageService() {
    return _instance;
  }

  LanguageService._internal();

  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _currentLanguage = 'en';
  bool _isLoading = false;

  String get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;

  // Language codes and names
  static const Map<String, String> languages = {
    'en': 'English',
    'hi': 'हिंदी',
    'mr': 'मराठी',
    'pa': 'ਪੰਜਾਬੀ',
    'gu': 'ગુજરાતી',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'kn': 'ಕನ್ನಡ',
    'bn': 'বাংলা',
    'ml': 'മലയാളം',
  };

  /// Initialize language service by loading saved preference
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = _authService.currentUserId;
      if (userId == null) {
        print('No user logged in');
        _currentLanguage = 'en'; // Default language
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Try to fetch language preference from Firestore
      final userDoc = await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final language = userDoc.data()!['language'] as String?;
        if (language != null && languages.containsKey(language)) {
          _currentLanguage = language;
        }
      }
    } catch (e) {
      print('Error loading language preference: $e');
      _currentLanguage = 'en'; // Default language on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save language preference to Firestore
  Future<bool> setLanguage(String languageCode) async {
    try {
      if (!languages.containsKey(languageCode)) {
        print('Invalid language code: $languageCode');
        return false;
      }

      final userId = _authService.currentUserId;
      if (userId == null) {
        print('No user logged in');
        return false;
      }

      // Update language in Firestore
      await _db
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'language': languageCode,
        'updatedAt': FieldValue.serverTimestamp(),
      }).catchError((e) {
        // If document doesn't exist, create it
        print('Error updating language: $e');
        return _db
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .set({
          'language': languageCode,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });

      _currentLanguage = languageCode;
      notifyListeners();
      print('Language saved: $languageCode (${languages[languageCode]})');
      return true;
    } catch (e) {
      print('Error saving language preference: $e');
      return false;
    }
  }

  /// Get locale from language code
  Locale getLocale() {
    final parts = _currentLanguage.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(_currentLanguage);
  }

  /// Get human-readable language name
  String getLanguageName(String code) {
    return languages[code] ?? 'Unknown';
  }

  /// Get all available languages
  List<MapEntry<String, String>> getAvailableLanguages() {
    return languages.entries.toList();
  }
}

