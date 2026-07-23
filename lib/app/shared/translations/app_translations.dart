import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static const Locale fallbackLocale = Locale('id');
  static final currentLocale = fallbackLocale.obs;

  static final Map<String, Map<String, String>> _keys = {};

  static Future<void> init() async {
    const langCode = 'id';
    try {
      final jsonString = await rootBundle.loadString('assets/locales/$langCode.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      _keys[langCode] = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      debugPrint('Error loading translation file for $langCode: $e');
      _keys[langCode] = {};
    }
  }

  @override
  Map<String, Map<String, String>> get keys => _keys;
}
