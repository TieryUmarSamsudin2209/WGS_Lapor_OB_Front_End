import 'dart:convert';
import 'dart:io';

import 'lib/app/shared/translations/en.dart';
import 'lib/app/shared/translations/id.dart';
import 'lib/app/shared/translations/ja.dart';

void main() {
  final targetDir = Directory('assets/locales');
  if (!targetDir.existsSync()) {
    targetDir.createSync(recursive: true);
  }

  // Convert and write ID
  final idFile = File('assets/locales/id.json');
  idFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(idTranslations));
  print('Successfully wrote id.json');

  // Convert and write EN
  final enFile = File('assets/locales/en.json');
  enFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(enTranslations));
  print('Successfully wrote en.json');

  // Convert and write JA
  final jaFile = File('assets/locales/ja.json');
  jaFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(jaTranslations));
  print('Successfully wrote ja.json');
}
