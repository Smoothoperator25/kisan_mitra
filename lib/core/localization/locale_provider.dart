import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_model.dart';

/// LocaleProvider
///
/// Manages the app's current locale using SharedPreferences for persistence.
/// Works pre-login so language can be selected on the Role Selection screen.
///
/// Usage in MaterialApp:
///   Consumer<LocaleProvider>(
///     builder: (context, provider, child) => MaterialApp(
///       locale: provider.currentLocale,
///       ...
///     ),
///   )
class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'selected_language';

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  String get currentLanguageCode => _currentLocale.languageCode;

  /// All supported languages — delegates to LanguageModel
  List<LanguageModel> get supportedLanguages =>
      LanguageModel.supportedLanguages;

  /// Load saved locale from SharedPreferences on app start.
  /// Falls back to English if none saved or if saved value is invalid.
  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefKey);

      if (savedCode != null) {
        final isValid = LanguageModel.supportedLanguages.any(
          (lang) => lang.code == savedCode,
        );
        if (isValid) {
          _currentLocale = Locale(savedCode);
        } else {
          // Invalid saved value → fallback to English
          _currentLocale = const Locale('en');
          await prefs.setString(_prefKey, 'en');
        }
      }
      // If nothing saved, keep default (English)
    } catch (e) {
      debugPrint('LocaleProvider: Error loading locale: $e');
      _currentLocale = const Locale('en');
    }
    notifyListeners();
  }

  /// Set a new locale and persist it to SharedPreferences.
  /// Triggers an immediate UI rebuild via notifyListeners.
  Future<void> setLocale(Locale locale) async {
    final isValid = LanguageModel.supportedLanguages.any(
      (lang) => lang.code == locale.languageCode,
    );

    if (!isValid) {
      debugPrint(
        'LocaleProvider: Unsupported locale ${locale.languageCode}, ignoring',
      );
      return;
    }

    if (_currentLocale == locale) return;

    _currentLocale = locale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, locale.languageCode);
      debugPrint('LocaleProvider: Locale saved → ${locale.languageCode}');
    } catch (e) {
      debugPrint('LocaleProvider: Error saving locale: $e');
    }
  }

  /// Convenience method to set locale by language code string
  Future<void> setLocaleByCode(String code) async {
    await setLocale(Locale(code));
  }
}
