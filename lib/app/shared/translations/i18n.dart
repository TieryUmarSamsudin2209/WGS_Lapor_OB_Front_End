import 'package:get/get.dart';
import '../utils/checklist_translation_key.dart';
import '../utils/report_translation_key.dart';

class I18n {
  /// Normalizes and translates dynamic database values (such as checklist tasks, reports, statuses, categories)
  /// using normalized keys. If not found in dynamic keys, falls back to GetX standard translation.
  static String translate(String value, [Map<String, String>? params]) {
    if (value.isEmpty) return value;

    // 1. Try standard GetX translations directly
    final direct = params != null ? value.trParams(params) : value.tr;
    if (direct != value) {
      return direct;
    }

    // 2. Try translating via checklist translation key mapping
    final checklistKey = checklistTranslationKey(value);
    if (checklistKey != value) {
      final trans = params != null ? checklistKey.trParams(params) : checklistKey.tr;
      if (trans != checklistKey) return trans;
    }

    // 3. Try translating via report translation key mapping
    final reportKey = reportTranslationKey(value);
    if (reportKey != value) {
      final trans = params != null ? reportKey.trParams(params) : reportKey.tr;
      if (trans != reportKey) return trans;
    }

    return value;
  }
}

extension I18nExtension on String {
  /// Dynamically translates the string. Resolves database/dynamic values as well.
  String trDynamic([Map<String, String>? params]) {
    return I18n.translate(this, params);
  }
}
