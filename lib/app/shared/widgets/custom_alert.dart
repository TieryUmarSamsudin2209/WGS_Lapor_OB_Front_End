import 'package:flutter/material.dart';

class CustomAlert {
  /// Simple fallback alert used by ReportPage to show success/failure.
  static void show(BuildContext context, {bool isSuccess = true, String? message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isSuccess ? 'Berhasil' : 'Gagal'),
        content: Text(message ?? (isSuccess ? 'Pengiriman laporan berhasil.' : 'Terjadi kesalahan.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
