import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.label,
    required this.nativeLabel,
  });

  final String code;
  final String label;
  final String nativeLabel;

  Locale get locale => Locale(code);
}

class AppTranslations extends Translations {
  static const String _localeStorageKey = 'app_locale';
  static const Locale fallbackLocale = Locale('id');
  static final currentLocale = fallbackLocale.obs;

  static final Map<String, Map<String, String>> _keys = {};

  static const List<AppLanguage> languages = [
    AppLanguage(
      code: 'id',
      label: 'Indonesian',
      nativeLabel: 'Bahasa Indonesia',
    ),
    AppLanguage(
      code: 'en',
      label: 'English',
      nativeLabel: 'English',
    ),
    AppLanguage(
      code: 'ja',
      label: 'Japanese',
      nativeLabel: '日本語',
    ),
  ];

  static Future<void> init() async {
    for (final lang in languages) {
      try {
        final jsonString = await rootBundle.loadString('assets/locales/${lang.code}.json');
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        _keys[lang.code] = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        debugPrint('Error loading translation file for ${lang.code}: $e');
        _keys[lang.code] = {};
      }
    }
  }

  static Future<Locale> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final locale = localeFromCode(prefs.getString(_localeStorageKey));
    setInitialLocale(locale);
    return locale;
  }

  static void setInitialLocale(Locale locale) {
    currentLocale.value = locale;
    Get.locale = locale;
  }

  static Future<void> updateLocale(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeStorageKey, language.code);
    currentLocale.value = language.locale;
    await Get.updateLocale(language.locale);
  }

  static Locale localeFromCode(String? code) {
    return languageFromCode(code)?.locale ?? fallbackLocale;
  }

  static AppLanguage? languageFromCode(String? code) {
    if (code == null || code.isEmpty) return null;
    for (final language in languages) {
      if (language.code == code) return language;
    }
    return null;
  }

  static AppLanguage currentLanguage() {
    final code = currentLocale.value.languageCode;
    return languageFromCode(code) ??
        languageFromCode(fallbackLocale.languageCode)!;
  }

  static String currentLanguageLabel() => currentLanguage().nativeLabel;

  @override
  Map<String, Map<String, String>> get keys => _keys;
}
