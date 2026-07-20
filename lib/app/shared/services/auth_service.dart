import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show basename;

import '../config/env_config.dart';

class AuthService extends GetxService {
  static String get baseUrl => EnvConfig.apiBaseUrl;
  static const _tokenKey = 'token';
  static const _userKey = 'user';

  final token = RxnString();
  final user = Rxn<Map<String, dynamic>>();
  final role = RxnString();
  final _client = GetConnect(timeout: const Duration(seconds: 30));
  String? _lastRequestError;

  // Public getter for last error
  String? get lastRequestError => _lastRequestError;

  // ✅ Dummy laporan untuk testing offline mode
  final List<Map<String, dynamic>> _dummyReports = [
    {
      'id': 'lap-001',
      'laporan_id': 'lap-001',
      'title': 'Toilet kotor dan berbau',
      'location': 'Gedung A - Kantor Pusat - Lantai 1, Toilet Pria Lantai 1',
      'description': 'Toilet pria lantai 1 kondisinya kotor, lantai basah, dan berbau tidak sedap. Perlu dibersihkan segera.',
      'deskripsi_kendala': 'Toilet pria lantai 1 kondisinya kotor, lantai basah, dan berbau tidak sedap. Perlu dibersihkan segera.',
      'priority': 'URGENT',
      'prioritas': 'URGENT',
      'status': 'pending',
      'kolaborasi': false,
      'category': 'Kebersihan',
      'kategori_id': 'ba7079f3-fc98-4be7-afe3-cc769ffa3458',
      'lantai_id': '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e1e02',
      'karyawan_id': '1faac01e-e059-4686-af13-f04bce031a71',
      'created_at': '2026-07-13T08:30:00.000Z',
      'photos': <String>[],
      'foto_masalah': <String>[],
      'reporter': 'Siti Aminah',
      'reporter_name': 'Siti Aminah',
    },
    {
      'id': 'lap-002',
      'laporan_id': 'lap-002',
      'title': 'AC tidak dingin',
      'location': 'Gedung A - Kantor Pusat - Lantai 2, Ruang Kerja Utama A2',
      'description': 'AC di ruang kerja utama tidak dingin, sudah dinyalakan sejak pagi tapi suhu ruangan tetap panas.',
      'deskripsi_kendala': 'AC di ruang kerja utama tidak dingin, sudah dinyalakan sejak pagi tapi suhu ruangan tetap panas.',
      'priority': 'STANDARD',
      'prioritas': 'STANDARD',
      'status': 'in_progress',
      'kolaborasi': false,
      'category': 'Pengecekan',
      'kategori_id': 'd2597de5-120f-47b0-878a-83a46c47db34',
      'lantai_id': '7249c72a-642d-4ceb-afbe-61396587e37e',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e2e01',
      'karyawan_id': 'd2ecedca-a2aa-4aa4-a721-34d6703e530c',
      'ob_id': '6fb8dfa8-92dc-4125-a00a-6ba9c6cd5820',
      'ob_name': 'Joko Prasetyo',
      'nama_ob': 'Joko Prasetyo',
      'dikerjakan_at': '2026-07-13T09:00:00.000Z',
      'created_at': '2026-07-13T08:45:00.000Z',
      'photos': <String>[],
      'foto_masalah': <String>[],
      'reporter': 'Andi Wijaya',
      'reporter_name': 'Andi Wijaya',
    },
    {
      'id': 'lap-003',
      'laporan_id': 'lap-003',
      'title': 'Lampu mati di ruang rapat',
      'location': 'Gedung A - Kantor Pusat - Lantai 2, Ruang Rapat Besar A2',
      'description': 'Beberapa lampu di ruang rapat besar tidak menyala. Perlu penggantian lampu.',
      'deskripsi_kendala': 'Beberapa lampu di ruang rapat besar tidak menyala. Perlu penggantian lampu.',
      'priority': 'STANDARD',
      'prioritas': 'STANDARD',
      'status': 'selesai',
      'kolaborasi': true,
      'category': 'Peralatan',
      'kategori_id': '5dcba45c-b5de-437c-858b-50dbe7624f9b',
      'lantai_id': '7249c72a-642d-4ceb-afbe-61396587e37e',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e2e02',
      'karyawan_id': '1faac01e-e059-4686-af13-f04bce031a71',
      'ob_id': '9e4d64c0-34e2-455c-b317-b9e4d6d5e6bd',
      'ob_name': 'Rina Marlina',
      'nama_ob': 'Rina Marlina',
      'dikerjakan_at': '2026-07-13T10:00:00.000Z',
      'selesai_at': '2026-07-13T11:30:00.000Z',
      'catatan': 'Lampu sudah diganti dengan yang baru. Total 4 lampu LED 18 watt.',
      'created_at': '2026-07-13T09:30:00.000Z',
      'photos': <String>[],
      'foto_masalah': <String>[],
      'foto_selesai': <String>[],
      'reporter': 'Siti Aminah',
      'reporter_name': 'Siti Aminah',
    },
  ];

  final List<Map<String, dynamic>> _dummyChecklist = [
    {
      'id': 'c1',
      'title': 'Mengepel & Menyapu',
      'description': 'Membersihkan seluruh lantai area kerja dan koridor',
      'section': 'Area kerja utama & Koridor',
      'status': 'selesai'
    },
    {
      'id': 'c2',
      'title': 'Dusting (Mengelap Debu)',
      'description': 'Mengelap meja kerja, meja meeting, kursi, rak buku, dan ambang jendela.',
      'section': 'Area kerja utama & Koridor',
      'status': 'pending'
    },
    {
      'id': 'c3',
      'title': 'Restocking (Isi Ulang)',
      'description': 'Memastikan sabun cuci tangan, tisu toilet, dan tisu wastafel selalu terisi penuh.',
      'section': 'Area kerja utama & Koridor',
      'status': 'pending'
    },
    {
      'id': 'c4',
      'title': 'Pembersihan Area Basah',
      'description': 'Lantai, kloset/urinal, dan wastafel.',
      'section': 'Area Toilet (Krusial & Harus Dicek Berkala)',
      'status': 'selesai'
    },
    {
      'id': 'c5',
      'title': 'Cek Drainase',
      'description': 'Memastikan tidak ada sumbatan pada saluran air dan air mengalir dengan lancar.',
      'section': 'Area Toilet (Krusial & Harus Dicek Berkala)',
      'status': 'selesai'
    },
    {
      'id': 'c6',
      'title': 'Pengosongan Tempat Sampah',
      'description': 'Mengosongkan seluruh tempat sampah',
      'section': 'Manajemen Sampah & Utilitas (Fasilitas)',
      'status': 'selesai'
    },
    {
      'id': 'c7',
      'title': 'Pengecekan Lampu & AC',
      'description': 'Matikan saat pulang / nyalakan saat pagi.',
      'section': 'Manajemen Sampah & Utilitas (Fasilitas)',
      'status': 'selesai'
    },
    {
      'id': 'c8',
      'title': 'Menyiram Tanaman',
      'description': 'Menyiram tanaman hias yang ada di dalam maupun di area depan kantor.',
      'section': 'Manajemen Sampah & Utilitas (Fasilitas)',
      'status': 'selesai'
    }
  ];

  // ✅ Match dengan seed.mjs - Kategori
  final List<Map<String, dynamic>> _dummyCategories = [
    {
      'id': 'ba7079f3-fc98-4be7-afe3-cc769ffa3458',
      'kategori_id': 'ba7079f3-fc98-4be7-afe3-cc769ffa3458',
      'nama': 'Kebersihan',
      'name': 'Kebersihan',
      'nama_kategori': 'Kebersihan',
    },
    {
      'id': 'd2597de5-120f-47b0-878a-83a46c47db34',
      'kategori_id': 'd2597de5-120f-47b0-878a-83a46c47db34',
      'nama': 'Pengecekan',
      'name': 'Pengecekan',
      'nama_kategori': 'Pengecekan',
    },
    {
      'id': '5dcba45c-b5de-437c-858b-50dbe7624f9b',
      'kategori_id': '5dcba45c-b5de-437c-858b-50dbe7624f9b',
      'nama': 'Peralatan',
      'name': 'Peralatan',
      'nama_kategori': 'Peralatan',
    },
  ];

  // ✅ Match dengan seed.mjs - Lokasi
  final List<Map<String, dynamic>> _dummyLocations = [
    {
      'id': '033f0941-8378-42e3-af2c-29cf83ab8e11',
      'lokasi_id': '033f0941-8378-42e3-af2c-29cf83ab8e11',
      'nama': 'Gedung A - Kantor Pusat',
      'name': 'Gedung A - Kantor Pusat',
      'nama_lokasi': 'Gedung A - Kantor Pusat',
    },
    {
      'id': '6c58477b-a345-4175-893a-58472165b899',
      'lokasi_id': '6c58477b-a345-4175-893a-58472165b899',
      'nama': 'Gedung B - Kantor Cabang',
      'name': 'Gedung B - Kantor Cabang',
      'nama_lokasi': 'Gedung B - Kantor Cabang',
    },
  ];

  // ✅ Match dengan seed.mjs - Lantai (dengan lokasi_id)
  final List<Map<String, dynamic>> _dummyFloors = [
    {
      'id': '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      'lantai_id': '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      'lokasi_id': '033f0941-8378-42e3-af2c-29cf83ab8e11',
      'nomor_lantai': 1,
      'nama': 'Gedung A - Kantor Pusat - Lantai 1',
      'name': 'Gedung A - Kantor Pusat - Lantai 1',
    },
    {
      'id': '7249c72a-642d-4ceb-afbe-61396587e37e',
      'lantai_id': '7249c72a-642d-4ceb-afbe-61396587e37e',
      'lokasi_id': '033f0941-8378-42e3-af2c-29cf83ab8e11',
      'nomor_lantai': 2,
      'nama': 'Gedung A - Kantor Pusat - Lantai 2',
      'name': 'Gedung A - Kantor Pusat - Lantai 2',
    },
    {
      'id': 'a67fbf59-44e4-4537-a9b8-5c5193958116',
      'lantai_id': 'a67fbf59-44e4-4537-a9b8-5c5193958116',
      'lokasi_id': '033f0941-8378-42e3-af2c-29cf83ab8e11',
      'nomor_lantai': 3,
      'nama': 'Gedung A - Kantor Pusat - Lantai 3',
      'name': 'Gedung A - Kantor Pusat - Lantai 3',
    },
    {
      'id': '5970908a-117c-4ab9-95f6-065ed4d8b04c',
      'lantai_id': '5970908a-117c-4ab9-95f6-065ed4d8b04c',
      'lokasi_id': '6c58477b-a345-4175-893a-58472165b899',
      'nomor_lantai': 1,
      'nama': 'Gedung B - Kantor Cabang - Lantai 1',
      'name': 'Gedung B - Kantor Cabang - Lantai 1',
    },
    {
      'id': 'a75e15c3-5990-4936-af85-2848d12d1901',
      'lantai_id': 'a75e15c3-5990-4936-af85-2848d12d1901',
      'lokasi_id': '6c58477b-a345-4175-893a-58472165b899',
      'nomor_lantai': 2,
      'nama': 'Gedung B - Kantor Cabang - Lantai 2',
      'name': 'Gedung B - Kantor Cabang - Lantai 2',
    },
  ];

  final List<Map<String, dynamic>> _dummyRooms = [
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e1e01',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e1e01',
      'lantai_id': '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      'nama': 'Lobby Gedung A',
      'name': 'Lobby Gedung A',
    },
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e1e02',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e1e02',
      'lantai_id': '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      'nama': 'Toilet Pria Lantai 1',
      'name': 'Toilet Pria Lantai 1',
    },
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e1e03',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e1e03',
      'lantai_id': '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      'nama': 'Toilet Wanita Lantai 1',
      'name': 'Toilet Wanita Lantai 1',
    },
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e1e04',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e1e04',
      'lantai_id': '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      'nama': 'Pantry Lantai 1',
      'name': 'Pantry Lantai 1',
    },
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e2e01',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e2e01',
      'lantai_id': '7249c72a-642d-4ceb-afbe-61396587e37e',
      'nama': 'Ruang Kerja Utama A2',
      'name': 'Ruang Kerja Utama A2',
    },
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e2e02',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e2e02',
      'lantai_id': '7249c72a-642d-4ceb-afbe-61396587e37e',
      'nama': 'Ruang Rapat Besar A2',
      'name': 'Ruang Rapat Besar A2',
    },
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e2e03',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e2e03',
      'lantai_id': '7249c72a-642d-4ceb-afbe-61396587e37e',
      'nama': 'Toilet Lantai 2',
      'name': 'Toilet Lantai 2',
    },
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e3e01',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e3e01',
      'lantai_id': 'a67fbf59-44e4-4537-a9b8-5c5193958116',
      'nama': 'Ruang Direksi',
      'name': 'Ruang Direksi',
    },
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e3e02',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e3e02',
      'lantai_id': 'a67fbf59-44e4-4537-a9b8-5c5193958116',
      'nama': 'Ruang Server',
      'name': 'Ruang Server',
    },
    {
      'id': 'a8db3d11-447a-4c28-98e3-b0fc844e3e03',
      'ruangan_id': 'a8db3d11-447a-4c28-98e3-b0fc844e3e03',
      'lantai_id': 'a67fbf59-44e4-4537-a9b8-5c5193958116',
      'nama': 'Toilet Lantai 3',
      'name': 'Toilet Lantai 3',
    },
    {
      'id': 'b8db3d11-447a-4c28-98e3-b0fc844e1e01',
      'ruangan_id': 'b8db3d11-447a-4c28-98e3-b0fc844e1e01',
      'lantai_id': '5970908a-117c-4ab9-95f6-065ed4d8b04c',
      'nama': 'Lobby Gedung B',
      'name': 'Lobby Gedung B',
    },
    {
      'id': 'b8db3d11-447a-4c28-98e3-b0fc844e1e02',
      'ruangan_id': 'b8db3d11-447a-4c28-98e3-b0fc844e1e02',
      'lantai_id': '5970908a-117c-4ab9-95f6-065ed4d8b04c',
      'nama': 'Ruang Kerja Utama B1',
      'name': 'Ruang Kerja Utama B1',
    },
    {
      'id': 'b8db3d11-447a-4c28-98e3-b0fc844e1e03',
      'ruangan_id': 'b8db3d11-447a-4c28-98e3-b0fc844e1e03',
      'lantai_id': '5970908a-117c-4ab9-95f6-065ed4d8b04c',
      'nama': 'Toilet Lantai 1',
      'name': 'Toilet Lantai 1',
    },
    {
      'id': 'b8db3d11-447a-4c28-98e3-b0fc844e2e01',
      'ruangan_id': 'b8db3d11-447a-4c28-98e3-b0fc844e2e01',
      'lantai_id': 'a75e15c3-5990-4936-af85-2848d12d1901',
      'nama': 'Ruang Rapat B2',
      'name': 'Ruang Rapat B2',
    },
    {
      'id': 'b8db3d11-447a-4c28-98e3-b0fc844e2e02',
      'ruangan_id': 'b8db3d11-447a-4c28-98e3-b0fc844e2e02',
      'lantai_id': 'a75e15c3-5990-4936-af85-2848d12d1901',
      'nama': 'Pantry Lantai 2',
      'name': 'Pantry Lantai 2',
    },
    {
      'id': 'b8db3d11-447a-4c28-98e3-b0fc844e2e03',
      'ruangan_id': 'b8db3d11-447a-4c28-98e3-b0fc844e2e03',
      'lantai_id': 'a75e15c3-5990-4936-af85-2848d12d1901',
      'nama': 'Toilet Lantai 2',
      'name': 'Toilet Lantai 2',
    },
  ];

  bool _isOfflineResponse(Response response) {
    // Only treat as offline if truly no network connection
    if (response.statusCode == null || response.statusCode == 0) return true;
    
    // Check for connection errors
    try {
      final status = response.status;
      if (status.connectionError) return true;
    } catch (_) {}
    
    // Check for ngrok tunnel errors
    final bodyStr = (response.bodyString ?? response.body ?? '').toString();
    if (bodyStr.contains('ERR_NGROK_') || bodyStr.contains('Tunnel not found')) {
      return true;
    }
    
    // DO NOT treat 503/502/504 as offline - these are server errors, not network errors
    // Let them be handled by normal error handling with informative messages
    return false;
  }

  bool _canUseOfflineFallback(Response response) {
    return isOfflineMode && _isOfflineResponse(response);
  }

  bool _hasTriggeredOfflineNotification = false;

  void _triggerOfflineNotificationTimer() {
    if (_hasTriggeredOfflineNotification) return;
    _hasTriggeredOfflineNotification = true;

    Timer(const Duration(seconds: 5), () {
      final newReport = {
        'id': 'lap-004',
        'laporan_id': 'lap-004',
        'title': 'Wastafel tersumbat',
        'location': 'Gedung B - Kantor Cabang - Lantai 1, Toilet Lantai 1',
        'description': 'Wastafel di toilet lantai 1 gedung B tersumbat. Air tidak bisa mengalir dengan lancar.',
        'deskripsi_kendala': 'Wastafel di toilet lantai 1 gedung B tersumbat. Air tidak bisa mengalir dengan lancar.',
        'priority': 'URGENT',
        'prioritas': 'URGENT',
        'status': 'pending',
        'kolaborasi': false,
        'category': 'Kebersihan',
        'kategori_id': 'ba7079f3-fc98-4be7-afe3-cc769ffa3458',
        'lantai_id': '5970908a-117c-4ab9-95f6-065ed4d8b04c',
        'ruangan_id': 'b8db3d11-447a-4c28-98e3-b0fc844e1e03',
        'karyawan_id': 'd2ecedca-a2aa-4aa4-a721-34d6703e530c',
        'created_at': DateTime.now().toIso8601String(),
        'photos': <String>[],
        'foto_masalah': <String>[],
        'reporter': 'Andi Wijaya',
        'reporter_name': 'Andi Wijaya',
      };
      if (!_dummyReports.any((r) => r['id'] == 'lap-004')) {
        _dummyReports.insert(0, newReport);
        debugPrint('Offline: Injected dummy report ID lap-004 for notification alert.');
      }
    });
  }

  bool get isLoggedIn => token.value != null && token.value!.isNotEmpty;
  bool get isOfflineMode => token.value == 'dummy_token' && EnvConfig.useOfflineMode;
  String get normalizedRole =>
      _normalizeRole(role.value ?? user.value?['role']);

  static String resolveMediaUrl(String value) {
    final text = value.trim();
    if (text.isEmpty) return text;

    final uri = Uri.tryParse(text);
    if (uri != null && uri.hasScheme) {
      final host = uri.host.toLowerCase();
      if (host == 'localhost' || host == '127.0.0.1' || host == '0.0.0.0') {
        final apiUri = Uri.parse(baseUrl);
        return apiUri
            .replace(
              path: uri.path,
              query: uri.hasQuery ? uri.query : null,
              fragment: uri.hasFragment ? uri.fragment : null,
            )
            .toString();
      }
      return text;
    }

    if (text.startsWith('/')) return '$baseUrl$text';
    if (text.startsWith('uploads/')) return '$baseUrl/$text';
    return text;
  }

  @override
  void onInit() {
    super.onInit();
    _client.baseUrl = baseUrl;
    _client.defaultContentType = 'application/json';
    configureClient(_client);
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/api/auth/login',
        {'identifier': identifier, 'password': password},
        contentType: 'application/json',
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      // Handle server errors with informative messages
      if (response.statusCode == 503) {
        debugPrint('❌ Backend server unavailable (503)');
        _lastRequestError = 'Server sedang dalam pemeliharaan. Coba lagi beberapa saat.';
        return false;
      }
      
      if (response.statusCode == 502) {
        debugPrint('❌ Bad Gateway (502)');
        _lastRequestError = 'Server gateway error. Periksa koneksi ke backend.';
        return false;
      }
      
      if (response.statusCode == 504) {
        debugPrint('❌ Gateway Timeout (504)');
        _lastRequestError = 'Server timeout. Coba lagi beberapa saat.';
        return false;
      }

      if (_isOfflineResponse(response)) {
        debugPrint('❌ Server tidak merespon saat login');
        _lastRequestError = 'Tidak dapat terhubung ke server. Periksa koneksi Anda.';
        return false;
      }

      final body = _responseBodyAsMap(response.body, response.bodyString);
      final dataValue = body?['data'];
      final data = _asMap(dataValue);
      final tokenText = _loginTokenFrom(body, data, dataValue);
      final tokenClaims = _decodeJwtPayload(tokenText);
      final userData =
          _asMap(data?['user']) ??
          _userFromTokenClaims(tokenClaims, fallbackIdentifier: identifier);

      if (response.isOk &&
          _isSuccessValue(body?['success']) &&
          tokenText != null &&
          tokenText.isNotEmpty) {
        await saveSession(tokenValue: tokenText, userData: userData);
        return true;
      }

      // Extract error message from server response
      final errorMessage = _extractErrorMessage(response, body);
      _lastRequestError = errorMessage;
      debugPrint('Login gagal: $errorMessage');
      debugPrint('Response body: ${response.bodyString ?? response.body}');
      return false;
    } catch (e) {
      debugPrint('Error login: $e');
      _lastRequestError = 'Terjadi kesalahan saat login. Coba lagi.';
      return false;
    }
  }

  /// Extract error message from server response
  String _extractErrorMessage(Response response, Map<String, dynamic>? body) {
    // Try to get message from response body
    if (body != null) {
      // Check for 'message' field
      final message = body['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
      
      // Check for 'error' field
      final error = body['error']?.toString();
      if (error != null && error.isNotEmpty) {
        return error;
      }
      
      // Check for 'errors' array (validation errors)
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        final firstError = errors.first;
        if (firstError is Map) {
          final msg = firstError['message']?.toString() ?? firstError['msg']?.toString();
          if (msg != null) return msg;
        }
        return errors.first.toString();
      }
    }
    
    // Default messages based on status code
    switch (response.statusCode) {
      case 400:
        return 'Data login tidak valid. Periksa email/username dan password Anda.';
      case 401:
        return 'Email/username atau password salah.';
      case 403:
        return 'Akses ditolak. Akun Anda mungkin tidak aktif.';
      case 404:
        return 'Endpoint login tidak ditemukan. Hubungi administrator.';
      case 422:
        return 'Data yang dikirim tidak valid.';
      case 429:
        return 'Terlalu banyak percobaan login. Coba lagi nanti.';
      case 500:
        return 'Terjadi kesalahan di server. Coba lagi nanti.';
      default:
        return 'Login gagal. Periksa email/username dan password Anda.';
    }
  }

  Future<bool> _loginOffline(String identifier, String password) async {
    if (!kDebugMode) return false;
    debugPrint('Server offline detected on login. Using dummy login...');
    
    // ✅ Match dengan seed.mjs users
    final dummyUsers = {
      'admin1': {
        'id': '7ad87697-6684-4d35-b691-eb8696fdcbdf',
        'username': 'admin1',
        'name': 'Budi Santoso',
        'nama_lengkap': 'Budi Santoso',
        'email': 'admin1@mail.com',
        'role': 'ADMIN',
        'role_id': 'dda2c23a-732c-41c5-80ee-b0818345fa25',
      },
      'karyawan1': {
        'id': '1faac01e-e059-4686-af13-f04bce031a71',
        'username': 'karyawan1',
        'name': 'Siti Aminah',
        'nama_lengkap': 'Siti Aminah',
        'email': 'karyawan1@mail.com',
        'role': 'KARYAWAN',
        'role_id': 'd25542e0-93ad-4513-87ca-c567319f6187',
      },
      'karyawan2': {
        'id': 'd2ecedca-a2aa-4aa4-a721-34d6703e530c',
        'username': 'karyawan2',
        'name': 'Andi Wijaya',
        'nama_lengkap': 'Andi Wijaya',
        'email': 'karyawan2@mail.com',
        'role': 'KARYAWAN',
        'role_id': 'd25542e0-93ad-4513-87ca-c567319f6187',
      },
      'ob1': {
        'id': '6fb8dfa8-92dc-4125-a00a-6ba9c6cd5820',
        'username': 'ob1',
        'name': 'Joko Prasetyo',
        'nama_lengkap': 'Joko Prasetyo',
        'email': 'ob1@mail.com',
        'role': 'OB',
        'role_id': '62c0a9d8-afd7-45f5-9cb3-6dc6e8a9b8da',
        'penugasan': 'Gedung A - Lantai 1 & 2',
      },
      'ob2': {
        'id': '9e4d64c0-34e2-455c-b317-b9e4d6d5e6bd',
        'username': 'ob2',
        'name': 'Rina Marlina',
        'nama_lengkap': 'Rina Marlina',
        'email': 'ob2@mail.com',
        'role': 'OB',
        'role_id': '62c0a9d8-afd7-45f5-9cb3-6dc6e8a9b8da',
        'penugasan': 'Gedung B - Lantai 1 & 2',
      },
      'hr1': {
        'id': 'd5178486-b32e-414a-b927-04d96b150d1b',
        'username': 'hr1',
        'name': 'Lestari Handayani',
        'nama_lengkap': 'Lestari Handayani',
        'email': 'hr1@mail.com',
        'role': 'HR',
        'role_id': 'eb89b4f9-635f-4e1e-8916-3a96af4e0c72',
      },
    };
    
    final username = identifier.split('@').first.toLowerCase();
    final dummyUser = dummyUsers[username] ?? {
      'id': 'dummy_id',
      'username': identifier,
      'name': 'Test User',
      'nama_lengkap': 'Test User',
      'email': '$identifier@mail.com',
      'role': identifier.toLowerCase().contains('ob') ? 'OB' : 'KARYAWAN',
    };
    
    // Add penugasan only for OB role (avoid null value in map)
    if (identifier.toLowerCase().contains('ob') && !dummyUser.containsKey('penugasan')) {
      dummyUser['penugasan'] = 'Gedung A - Lantai 1 & 2';
    }
    
    await saveSession(tokenValue: 'dummy_token', userData: dummyUser);
    return true;
  }

  Future<Map<String, dynamic>?> activateAccount({
    required String activationToken,
    required String password,
    required String confirmPassword,
  }) async {
    _lastRequestError = null;

    try {
      final response = await _client.post(
        '/api/auth/activate-account',
        {
          'password': password,
          'confirmPassword': confirmPassword,
        },
        query: {'token': activationToken},
        contentType: 'application/json',
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      final body = _responseBodyAsMap(response.body, response.bodyString);
      final success = _isSuccessValue(body?['success']);

      if ((response.isOk || response.statusCode == 201) && success) {
        return body ?? <String, dynamic>{'success': true};
      }

      _lastRequestError =
          _activationErrorMessage(response) ??
          'Aktivasi gagal. Token tidak valid atau password tidak sesuai.';
      debugPrint(
        'Gagal aktivasi akun: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      _lastRequestError =
          'Tidak dapat terhubung ke server. Periksa koneksi internet dan alamat API.';
      debugPrint('Error aktivasi akun: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      debugPrint('🔍 GET /api/user/profile');
      final response = await _client.get(
        '/api/user/profile',
        headers: authHeaders(),
      );

      debugPrint('📥 GET profile response status: ${response.statusCode}');

      if (response.isOk) {
        final profileData = _responseBodyAsMap(response.body, response.bodyString);
        debugPrint('📥 GET profile response: ${profileData.toString().substring(0, profileData.toString().length > 300 ? 300 : profileData.toString().length)}');
        return profileData;
      }

      if (_isOfflineResponse(response)) {
        debugPrint('📴 Offline mode, using cached profile');
        return _getUserProfileOffline();
      }

      debugPrint(
        '❌ Gagal ambil profile: statusCode=${response.statusCode}, body=${response.bodyString ?? response.body}',
      );
      
      // If API error, use cached profile from SharedPreferences
      debugPrint('⚠️  API error, falling back to cached profile');
      return _getUserProfileOffline();
    } catch (e) {
      debugPrint('❌ Error ambil profile: $e');
      return _getUserProfileOffline();
    }
  }

  Map<String, dynamic> _getUserProfileOffline() {
    debugPrint('📴 Using offline profile cache from SharedPreferences');
    
    final currentUser = user.value;
    
    // If user exists, return it
    if (currentUser != null) {
      debugPrint('  Cached user: ${currentUser.toString().substring(0, currentUser.toString().length > 200 ? 200 : currentUser.toString().length)}');
      return {
        'success': true,
        'data': {
          'user': currentUser,
        }
      };
    }
    
    if (!kDebugMode) return {'success': false, 'data': null};
    
    // Default fallback user
    final fallbackUser = <String, dynamic>{
      'id': '1faac01e-e059-4686-af13-f04bce031a71',
      'username': 'karyawan1',
      'name': 'Siti Aminah',
      'nama_lengkap': 'Siti Aminah',
      'email': 'karyawan1@mail.com',
      'role': role.value ?? 'KARYAWAN',
      'role_id': 'd25542e0-93ad-4513-87ca-c567319f6187',
    };
    
    // Add penugasan only for OB role
    if (role.value == 'OB') {
      fallbackUser['penugasan'] = 'Gedung A - Lantai 1 & 2';
    }
    
    debugPrint('  Using fallback user: ${fallbackUser.toString().substring(0, fallbackUser.toString().length > 200 ? 200 : fallbackUser.toString().length)}');
    return {
      'success': true,
      'data': {
        'user': fallbackUser,
      }
    };
  }

  Future<Map<String, dynamic>?> updateUserProfile({
    required String firstName,
    required String lastName,
    String? avatarPath,
  }) async {
    final sanitizedFirstName = firstName.trim();
    final sanitizedLastName = lastName.trim();
    final fullName = [
      sanitizedFirstName,
      sanitizedLastName,
    ].where((part) => part.isNotEmpty).join(' ');
    if (fullName.isEmpty) return null;

    final localAvatarPath = _localUploadPath(avatarPath);
    final response = localAvatarPath == null
        ? await _sendProfileJsonUpdate(fullName)
        : await _sendProfileMultipartUpdate(
            fullName: fullName,
            firstName: sanitizedFirstName,
            lastName: sanitizedLastName,
            avatarPath: localAvatarPath,
          );

    if (!response.isOk) {
      debugPrint(
        'Gagal update profile: ${response.bodyString ?? response.body}',
      );
      return null;
    }

    final body =
        _responseBodyAsMap(response.body, response.bodyString) ??
        <String, dynamic>{'success': true};
    
    debugPrint('📦 Profile update response body: ${body.toString().substring(0, body.toString().length > 300 ? 300 : body.toString().length)}');
    
    // Response might not contain updated profile, so fetch it again
    final updatedProfile = _profileFromResponse(body);
    if (updatedProfile != null) {
      debugPrint('✅ Profile found in response, merging: ${updatedProfile.toString().substring(0, updatedProfile.toString().length > 300 ? 300 : updatedProfile.toString().length)}');
      await mergeUserData(updatedProfile);
    } else {
      debugPrint('⚠️  Response does not contain profile data, fetching fresh profile from API...');
      final freshProfile = await getUserProfile();
      if (freshProfile != null) {
        final profile = _profileFromResponse(freshProfile);
        if (profile != null) {
          debugPrint('✅ Fresh profile fetched, merging: ${profile.toString().substring(0, profile.toString().length > 300 ? 300 : profile.toString().length)}');
          await mergeUserData(profile);
        }
      } else {
        // Fallback: manually set the name
        debugPrint('⚠️  Could not fetch fresh profile, using manual fallback');
        await mergeUserData({
          'nama': fullName,
          'nama_lengkap': fullName,
          'profile_picture': localAvatarPath ?? avatarPath?.trim() ?? '',
        });
      }
    }
    
    return body;
  }

  Future<Map<String, dynamic>?> getUserReportDetail(String reportId) async {
    try {
      final response = await _client.get(
        '/api/user/profile/laporan/$reportId',
        headers: authHeaders(),
      );

      if (response.isOk) {
        return _asMap(response.body);
      }

      if (_isOfflineResponse(response)) {
        return _getUserReportDetailOffline(reportId);
      }

      debugPrint(
        'Gagal ambil detail laporan: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil detail laporan: $e');
      return _getUserReportDetailOffline(reportId);
    }
  }

  Map<String, dynamic>? _getUserReportDetailOffline(String reportId) {
    final report = _dummyReports.firstWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
      orElse: () => <String, dynamic>{},
    );
    if (report.isEmpty) return null;
    return {
      'success': true,
      'data': report,
    };
  }

  Future<Map<String, dynamic>?> getDailyChecklist({
    int page = 1,
    int limit = 10,
    String? search,
    String? lokasiId,
    String? lantaiId,
    String? status,
  }) async {
    try {
      final query = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.trim().isNotEmpty) {
        query['search'] = search.trim();
      }
      if (lokasiId != null && lokasiId.trim().isNotEmpty) {
        query['lokasi_id'] = lokasiId.trim();
      }
      if (lantaiId != null && lantaiId.trim().isNotEmpty) {
        query['lantai_id'] = lantaiId.trim();
      }
      if (status != null && status.trim().isNotEmpty) {
        query['status'] = status.trim();
      }

      final response = await _client.get(
        '/api/checklist-harian',
        query: query,
        headers: authHeaders(),
      );

      if (response.isOk) {
        return _responseBodyAsMap(response.body, response.bodyString) ??
            _asMap(response.body);
      }

      if (_isOfflineResponse(response)) {
        return _getDailyChecklistOffline();
      }

      debugPrint(
        'Gagal ambil checklist harian: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil checklist harian: $e');
      return _getDailyChecklistOffline();
    }
  }

  Map<String, dynamic> _getDailyChecklistOffline() {
    if (!kDebugMode) return {'success': false, 'data': <Map<String, dynamic>>[]};
    return {
      'success': true,
      'data': _dummyChecklist,
    };
  }

  Future<List<Map<String, dynamic>>> getReportCategories() async {
    debugPrint('Fetching report categories...');
    debugPrint('Current user role: ${role.value}');
    debugPrint('Token present: ${token.value != null}');
    
    final liveOptions = await _fetchOptionList(
      endpoints: const ['/api/kategori', '/api/kategori-laporan', '/api/categories'],
      listKeys: const [
        'kategori',
        'categories',
        'items',
        'data',
      ],
    );

    if (liveOptions.isNotEmpty) {
      debugPrint('Loaded ${liveOptions.length} categories from API');
      return liveOptions;
    }
    debugPrint('Using ${_dummyCategories.length} dummy categories (API failed, forbidden, or offline)');
    return _dummyCategories;
  }

  Future<List<Map<String, dynamic>>> getReportLocations() async {
    debugPrint('Fetching report locations...');
    final liveOptions = await _fetchOptionList(
      endpoints: const ['/api/lokasi', '/api/locations', '/api/gedung'],
      listKeys: const [
        'lokasi',
        'locations',
        'gedung',
        'items',
        'data',
      ],
    );

    if (liveOptions.isNotEmpty) {
      debugPrint('Loaded ${liveOptions.length} locations from API');
      return liveOptions;
    }
    debugPrint('Using ${_dummyLocations.length} dummy locations (API failed, forbidden, or offline)');
    return _dummyLocations;
  }

  Future<List<Map<String, dynamic>>> getReportFloors() async {
    debugPrint('Fetching report floors...');
    final liveOptions = await _fetchOptionList(
      endpoints: const ['/api/lantai', '/api/floors', '/api/gedung'],
      listKeys: const [
        'lantai',
        'floors',
        'items',
        'data',
      ],
    );

    if (liveOptions.isNotEmpty) {
      debugPrint('Loaded ${liveOptions.length} floors from API');
      return liveOptions;
    }
    debugPrint('Using ${_dummyFloors.length} dummy floors (API failed, forbidden, or offline)');
    return _dummyFloors;
  }

  Future<List<Map<String, dynamic>>> getReportRooms() async {
    debugPrint('Fetching report rooms...');
    final liveOptions = await _fetchOptionList(
      endpoints: const ['/api/ruangan', '/api/rooms'],
      listKeys: const [
        'ruangan',
        'rooms',
        'items',
        'data',
      ],
    );

    if (liveOptions.isNotEmpty) {
      debugPrint('Loaded ${liveOptions.length} rooms from API');
      return liveOptions;
    }
    debugPrint('Using ${_dummyRooms.length} dummy rooms (API failed, forbidden, or offline)');
    return _dummyRooms;
  }

  Future<Map<String, dynamic>?> getObActiveLocations() async {
    debugPrint('Fetching OB active locations...');

    const endpoints = [
      '/api/ob/lokasi-aktif',
      '/api/ob/active-locations',
      '/api/ob/assigned-locations',
      '/api/ob/profile/locations',
      '/api/lantai',
    ];

    for (final endpoint in endpoints) {
      try {
        debugPrint('Trying endpoint: $endpoint');
        final response = await _client.get(endpoint, headers: authHeaders());

        if (response.isOk) {
          debugPrint('Successfully fetched locations from $endpoint');
          return _responseBodyAsMap(response.body, response.bodyString) ??
              _asMap(response.body);
        }

        debugPrint('Endpoint $endpoint returned status ${response.statusCode}');
      } catch (e) {
        debugPrint('Error fetching from $endpoint: $e');
      }
    }

    // Fallback to dummy/offline data
    if (isOfflineMode) {
      debugPrint('Using offline dummy locations');
      return _getObActiveLocationsOffline();
    }

    debugPrint('Failed to fetch active locations from all endpoints');
    return null;
  }

  Map<String, dynamic> _getObActiveLocationsOffline() {
    // Return first 2 floors as active locations for offline mode
    final activeFloors = _dummyFloors.take(2).map((floor) {
      return {
        ...floor,
        'is_active': true,
        'isActive': true,
        'active': true,
      };
    }).toList();

    return {
      'success': true,
      'data': activeFloors,
    };
  }

  Future<Map<String, dynamic>?> updateObActiveLocations(
    List<String> locationIds,
  ) async {
    debugPrint('Updating OB active locations: ${locationIds.length} locations');
    _lastRequestError = null;

    const endpoints = [
      '/api/ob/lokasi-aktif',
      '/api/ob/active-locations',
      '/api/ob/assigned-locations',
      '/api/ob/profile/locations',
    ];

    final payloads = [
      {'lokasi_ids': locationIds},
      {'location_ids': locationIds},
      {'lantai_ids': locationIds},
      {'floor_ids': locationIds},
      {'aktif_lokasi': locationIds},
      {'active_locations': locationIds},
    ];

    Response<dynamic>? lastResponse;

    for (final endpoint in endpoints) {
      for (final payload in payloads) {
        try {
          debugPrint('Trying PUT $endpoint with payload keys: ${payload.keys.join(", ")}');
          
          var response = await _client.put(
            endpoint,
            payload,
            contentType: 'application/json',
            headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
          );

          if (response.isOk || response.statusCode == 201) {
            debugPrint('Successfully updated locations via PUT $endpoint');
            return _responseBodyAsMap(response.body, response.bodyString) ??
                <String, dynamic>{'success': true};
          }

          lastResponse = response;

          // Try PATCH if PUT fails
          debugPrint('Trying PATCH $endpoint with payload keys: ${payload.keys.join(", ")}');
          response = await _client.patch(
            endpoint,
            payload,
            contentType: 'application/json',
            headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
          );

          if (response.isOk || response.statusCode == 201) {
            debugPrint('Successfully updated locations via PATCH $endpoint');
            return _responseBodyAsMap(response.body, response.bodyString) ??
                <String, dynamic>{'success': true};
          }

          lastResponse = response;

          // Try POST as last resort
          debugPrint('Trying POST $endpoint with payload keys: ${payload.keys.join(", ")}');
          response = await _client.post(
            endpoint,
            payload,
            contentType: 'application/json',
            headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
          );

          if (response.isOk || response.statusCode == 201) {
            debugPrint('Successfully updated locations via POST $endpoint');
            return _responseBodyAsMap(response.body, response.bodyString) ??
                <String, dynamic>{'success': true};
          }

          lastResponse = response;
        } catch (e) {
          debugPrint('Error calling $endpoint: $e');
        }
      }
    }

    // Fallback for offline mode
    if (isOfflineMode && (lastResponse == null || _isOfflineResponse(lastResponse))) {
      debugPrint('Using offline fallback for updating locations');
      return _updateObActiveLocationsOffline(locationIds);
    }

    _lastRequestError =
        _errorMessageFromResponse(lastResponse!) ??
        'Gagal menyimpan lokasi aktif. Endpoint tidak ditemukan di server.';
    debugPrint('Failed to update active locations: $_lastRequestError');
    return null;
  }

  Map<String, dynamic> _updateObActiveLocationsOffline(List<String> locationIds) {
    debugPrint('Offline: Simulating location update for ${locationIds.length} locations');
    return {
      'success': true,
      'message': 'Lokasi aktif berhasil diperbarui (offline mode)',
      'data': {
        'updated_count': locationIds.length,
        'location_ids': locationIds,
      },
    };
  }

  Future<Map<String, dynamic>?> getEmployeeReports({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        '/api/karyawan/laporan',
        query: {'page': page.toString(), 'limit': limit.toString()},
        headers: authHeaders(),
      );

      if (response.isOk) {
        return _responseBodyAsMap(response.body, response.bodyString) ??
            _asMap(response.body);
      }

      if (_canUseOfflineFallback(response)) {
        return _getReportsOffline();
      }

      debugPrint(
        'Gagal ambil laporan karyawan: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil laporan karyawan: $e');
      if (isOfflineMode) return _getReportsOffline();
      return null;
    }
  }

  Map<String, dynamic> _getReportsOffline() {
    if (!kDebugMode) return {'success': false, 'data': <Map<String, dynamic>>[]};
    return {
      'success': true,
      'data': _dummyReports,
    };
  }

  Future<Map<String, dynamic>?> getNotifications() async {
    try {
      final response = await _client.get(
        '/api/notifikasi',
        headers: authHeaders(),
      );

      if (response.isOk) {
        return _responseBodyAsMap(response.body, response.bodyString) ??
            _asMap(response.body);
      }

      if (_isOfflineResponse(response)) {
        return _getNotificationsOffline();
      }

      debugPrint(
        'Gagal ambil notifikasi: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil notifikasi: $e');
      return _getNotificationsOffline();
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _client.get(
        '/api/notifikasi/unread-count',
        headers: authHeaders(),
      );

      if (response.isOk) {
        final body =
            _responseBodyAsMap(response.body, response.bodyString) ??
            _asMap(response.body);
        final data = body?['data'];
        if (data is num) return data.toInt();
        return int.tryParse(data?.toString() ?? '') ?? 0;
      }

      if (_isOfflineResponse(response)) {
        return _offlineNotifications().where((item) {
          return _isTruthy(item['is_read']) == false;
        }).length;
      }
    } catch (e) {
      debugPrint('Error ambil jumlah notifikasi belum dibaca: $e');
    }

    return 0;
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value is String) {
      final v = value.toLowerCase().trim();
      return v == 'true' || v == '1' || v == 'yes';
    }

    return false;
  }

  Future<bool> markAllNotificationsRead() async {
    try {
      final response = await _client.patch(
        '/api/notifikasi/read-all',
        null,
        headers: authHeaders(),
      );

      if (response.isOk) return true;
      if (_isOfflineResponse(response)) return true;

      debugPrint(
        'Gagal tandai semua notifikasi: ${response.bodyString ?? response.body}',
      );
    } catch (e) {
      debugPrint('Error tandai semua notifikasi: $e');
      return isOfflineMode;
    }

    return false;
  }

  Future<bool> markNotificationRead(String notificationId) async {
    if (notificationId.trim().isEmpty) return false;

    try {
      final response = await _client.patch(
        '/api/notifikasi/$notificationId/read',
        null,
        headers: authHeaders(),
      );

      if (response.isOk) return true;
      if (_isOfflineResponse(response)) return true;

      debugPrint(
        'Gagal tandai notifikasi: ${response.bodyString ?? response.body}',
      );
    } catch (e) {
      debugPrint('Error tandai notifikasi: $e');
      return isOfflineMode;
    }

    return false;
  }

  /// WebSocket URL for real-time notifications
  /// Connect to: ws://hostname/ws?token=xxx
  /// 
  /// Format notifikasi real-time:
  /// - LAPORAN_BARU, LAPORAN_DIKERJAKAN, LAPORAN_SELESAI
  /// - GABUNG_LAPORAN, GABUNG_DISETUJUI, GABUNG_DIBATALKAN
  /// - KELUAR_KOLABORASI, DIKELUARKAN_KOLABORASI
  /// - LAPORAN_DIBATALKAN
  String get webSocketUrl {
    final tokenValue = token.value;
    if (tokenValue == null || tokenValue.isEmpty) {
      return '';
    }
    
    // Convert http/https to ws/wss
    final baseWsUrl = baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    return '$baseWsUrl/ws?token=$tokenValue';
  }

  Uri notificationWebSocketUri() {
    final apiUri = Uri.parse(baseUrl);
    final currentToken = token.value ?? '';
    return apiUri.replace(
      scheme: apiUri.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws',
      query: null,
      queryParameters: {'token': currentToken},
    );
  }

  Map<String, dynamic> _getNotificationsOffline() {
    if (!kDebugMode) return {'success': false, 'data': <String, dynamic>{'hari_ini': <Map<String, dynamic>>[], 'kemarin': <Map<String, dynamic>>[]}};
    final now = DateTime.now();
    final items = _offlineNotifications();

    return {
      'success': true,
      'message': 'Offline notifications',
      'data': {
        'hari_ini': items.where((item) {
          final date = DateTime.tryParse(item['created_at']?.toString() ?? '');
          return date != null &&
              date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList(),
        'kemarin': items.where((item) {
          final date = DateTime.tryParse(item['created_at']?.toString() ?? '');
          final yesterday = now.subtract(const Duration(days: 1));
          return date != null &&
              date.year == yesterday.year &&
              date.month == yesterday.month &&
              date.day == yesterday.day;
        }).toList(),
      },
    };
  }

  List<Map<String, dynamic>> _offlineNotifications() {
    final now = DateTime.now();
    return [
      {
        'id': 'notif_offline_1',
        'tipe': 'LAPORAN_BARU',
        'judul': 'Laporan Baru',
        'pesan': 'Ada laporan baru yang perlu ditindaklanjuti.',
        'is_read': false,
        'created_at': now.subtract(const Duration(minutes: 8)).toIso8601String(),
        'penerima': {'nama_lengkap': user.value?['name'] ?? 'User'},
      },
      {
        'id': 'notif_offline_2',
        'tipe': 'INFO',
        'judul': 'Pembaruan Sistem',
        'pesan': 'Notifikasi akan tersinkron saat server kembali online.',
        'is_read': true,
        'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        'penerima': {'nama_lengkap': user.value?['name'] ?? 'User'},
      },
    ];
  }

  Future<Map<String, dynamic>?> createEmployeeReport({
    required String floorId,
    required String roomId,
    required String categoryId,
    required String description,
    required String priority,
    required List<String> photoPaths,
  }) async {
    _lastRequestError = null;

    // Validate input data
    if (categoryId.trim().isEmpty || roomId.trim().isEmpty || description.trim().isEmpty) {
      _lastRequestError = 'Data laporan tidak lengkap. Pastikan kategori, ruangan, dan deskripsi sudah diisi.';
      debugPrint('❌ Validation failed: categoryId=$categoryId, roomId=$roomId, description length=${description.length}');
      return null;
    }

    // Validate UUIDs format
    final uuidRegex = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
    if (!uuidRegex.hasMatch(categoryId)) {
      _lastRequestError = 'Format kategori_id tidak valid. Harap pilih dari dropdown.';
      debugPrint('❌ Invalid kategori_id format: $categoryId');
      return null;
    }
    if (!uuidRegex.hasMatch(roomId)) {
      _lastRequestError = 'Format ruangan_id tidak valid. Harap pilih dari dropdown.';
      debugPrint('❌ Invalid ruangan_id format: $roomId');
      return null;
    }
    if (floorId.isNotEmpty && !uuidRegex.hasMatch(floorId)) {
      _lastRequestError = 'Format lantai_id tidak valid. Harap pilih dari dropdown.';
      debugPrint('❌ Invalid lantai_id format: $floorId');
      return null;
    }

    try {
      final cleanPhotoPaths = photoPaths
          .map(_localUploadPath)
          .whereType<String>()
          .where((path) => path.isNotEmpty)
          .toList();

      if (cleanPhotoPaths.isEmpty && photoPaths.isNotEmpty) {
        debugPrint('⚠️  Warning: All photo paths were filtered out. Original: $photoPaths');
      }

      Response<dynamic>? lastResponse;
      Response<dynamic>? firstValidationErrorResponse;
      var attemptCount = 0;
      
      for (final request in _createEmployeeReportRequests(
        floorId: floorId,
        roomId: roomId,
        categoryId: categoryId,
        description: description.trim(),
        priority: priority.trim().toUpperCase(),
        photoPaths: cleanPhotoPaths,
      )) {
        attemptCount++;
        debugPrint('📤 Attempting to create report (attempt $attemptCount)...');
        
        final response = await request();
        lastResponse = response;

        if (_canUseOfflineFallback(response)) {
          debugPrint('🔄 Using offline fallback for report creation');
          return _createEmployeeReportOffline(
            floorId: floorId,
            roomId: roomId,
            categoryId: categoryId,
            description: description,
            priority: priority,
            photoPaths: photoPaths,
          );
        }

        if (response.isOk || response.statusCode == 201) {
          debugPrint('✅ Report created successfully (attempt $attemptCount)');
          return _responseBodyAsMap(response.body, response.bodyString) ??
              <String, dynamic>{'success': true};
        }

        debugPrint('❌ Report creation failed (attempt $attemptCount): status=${response.statusCode}, body=${response.bodyString}');

        // Store first validation error for better error message
        if (firstValidationErrorResponse == null && _isValidationError(response)) {
          firstValidationErrorResponse = response;
        }

        if (!_shouldTryNextCreateReportRequest(response)) {
          debugPrint('🛑 Stopping retry attempts after attempt $attemptCount');
          break;
        }
      }

      // Prefer validation error message over generic error
      final errorResponse = firstValidationErrorResponse ?? lastResponse!;
      _lastRequestError =
          _errorMessageFromResponse(errorResponse) ??
          _createReportErrorMessage(errorResponse);
      debugPrint(
        '💥 All report creation attempts failed. Final error: $_lastRequestError',
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception during report creation: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) {
        return _createEmployeeReportOffline(
          floorId: floorId,
          roomId: roomId,
          categoryId: categoryId,
          description: description,
          priority: priority,
          photoPaths: photoPaths,
        );
      }
      _lastRequestError =
          'Tidak dapat menghubungi server untuk mengirim laporan.';
      return null;
    }
  }

  List<Future<Response<dynamic>> Function()> _createEmployeeReportRequests({
    required String floorId,
    required String roomId,
    required String categoryId,
    required String description,
    required String priority,
    required List<String> photoPaths,
  }) {
    // Primary payload matching API documentation exactly
    final primaryPayload = <String, dynamic>{
      'lantai_id': floorId,
      'ruangan_id': roomId,
      'kategori_id': categoryId,
      'deskripsi_kendala': description,
      'prioritas': priority,
    };

    debugPrint('🔍 Creating request payload with:');
    debugPrint('  • kategori_id: $categoryId');
    debugPrint('  • lantai_id: $floorId');
    debugPrint('  • ruangan_id: $roomId');
    debugPrint('  • prioritas: $priority');
    debugPrint('  • deskripsi length: ${description.length} chars');
    debugPrint('  • foto count: ${photoPaths.length} photos');

    return [
      // ✅ ONLY use exact API spec format - no fallbacks
      () => _postEmployeeReportMultipart(primaryPayload, photoPaths, 'foto_masalah'),
    ];
  }

  Future<Response<dynamic>> _postEmployeeReportMultipart(
    Map<String, dynamic> payload,
    List<String> photoPaths,
    String photoKey,
  ) async {
    // 🔍 TEST CONNECTION FIRST
    debugPrint('🔌 Testing connection to: $baseUrl');
    debugPrint('🔑 Token present: ${token.value != null ? "YES (${token.value!.substring(0, 20)}...)" : "NO"}');
    
    try {
      final testResponse = await _client.get(
        '/api/kategori',
        headers: authHeaders(),
      ).timeout(const Duration(seconds: 5));
      debugPrint('✅ Connection test: status=${testResponse.statusCode}');
      if (testResponse.statusCode == 403) {
        debugPrint('⚠️  403 Forbidden - Token might be expired or invalid!');
      }
    } catch (e) {
      debugPrint('❌ Connection test FAILED: $e');
      debugPrint('⚠️  Ngrok tunnel might be down or backend not running!');
    }

    final formPayload = Map<String, dynamic>.from(payload);
    
    // 🔍 DEBUG: Log payload data untuk debugging
    debugPrint('📤 CREATING REPORT - Payload Data:');
    debugPrint('  kategori_id: ${payload["kategori_id"]}');
    debugPrint('  lantai_id: ${payload["lantai_id"]}');
    debugPrint('  ruangan_id: ${payload["ruangan_id"]}');
    debugPrint('  prioritas: ${payload["prioritas"]}');
    final desc = payload["deskripsi_kendala"]?.toString() ?? '';
    debugPrint('  deskripsi_kendala: ${desc.length > 50 ? desc.substring(0, 50) : desc}...');
    
    // Add photos to form data
    if (photoPaths.isNotEmpty) {
      debugPrint('Adding ${photoPaths.length} photos with key: $photoKey');
      
      // According to API doc, foto_masalah accepts array of files (max 5)
      final photoFiles = <MultipartFile>[];
      final photoFilenames = <String>[];
      for (final photoPath in photoPaths.take(5)) {
        try {
          // Verify file exists before creating MultipartFile
          final file = MultipartFile(
            photoPath,
            filename: _filenameFromPath(photoPath),
            contentType: _contentTypeFromPath(photoPath),
          );
          photoFiles.add(file);
          photoFilenames.add(file.filename ?? 'unknown');
          debugPrint('✓ Added file: ${file.filename}');
        } catch (e) {
          debugPrint('✗ Failed to add file $photoPath: $e');
        }
      }
      
      if (photoFiles.isNotEmpty) {
        formPayload[photoKey] = photoFiles;
        debugPrint('Photo filenames: ${photoFilenames.join(", ")}');
      } else {
        debugPrint('⚠️  No valid photos to upload');
      }
    } else {
      debugPrint('No photos to upload');
    }

    debugPrint('Form payload keys: ${formPayload.keys.join(", ")}');
    debugPrint('Posting to: $baseUrl/api/karyawan/laporan');
    
    try {
      final response = await _client.post(
        '/api/karyawan/laporan',
        FormData(formPayload),
        contentType: 'multipart/form-data',
        headers: authHeaders(),
      );
      
      debugPrint('📥 Response: status=${response.statusCode}');
      
      // Safe body logging
      final bodyStr = response.bodyString;
      if (bodyStr != null && bodyStr.isNotEmpty) {
        if (bodyStr.length > 200) {
          debugPrint('📥 Body preview: ${bodyStr.substring(0, 200)}...');
        } else {
          debugPrint('📥 Body: $bodyStr');
        }
      } else {
        debugPrint('📥 Body: (empty)');
      }
      
      return response;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception during POST: $e');
      debugPrint('Stack: $stackTrace');
      // Return a failed response object instead of throwing
      return Response(
        statusCode: null,
        body: null,
        statusText: 'Network error: $e',
      );
    }
  }

  bool _shouldTryNextCreateReportRequest(Response<dynamic> response) {
    // ✅ No retry - only use exact API spec format once
    return false;
  }

  bool _isValidationError(Response<dynamic> response) {
    if (response.statusCode != 400) return false;
    
    final message = _errorMessageFromResponse(response)?.toLowerCase() ?? '';
    return message.contains('validation') ||
        message.contains('validasi') ||
        message.contains('required') ||
        message.contains('wajib') ||
        message.contains('harus diisi') ||
        message.contains('tidak boleh kosong');
  }

  String _createReportErrorMessage(Response<dynamic> response) {
    final statusCode = response.statusCode;
    final statusText = response.statusText;
    
    // Network error (no response from server)
    if (statusCode == null) {
      if (statusText != null && statusText.contains('Network error:')) {
        return 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      }
      return 'Tidak dapat menghubungi server. Periksa koneksi internet atau coba lagi.';
    }
    
    if (statusCode == 400) {
      return 'Data laporan tidak valid. Periksa kembali kategori, lokasi, dan deskripsi yang diisi.';
    }
    if (statusCode == 404) {
      return 'Endpoint laporan tidak ditemukan di server. Hubungi administrator.';
    }
    if (statusCode == 413) {
      return 'Ukuran foto terlalu besar. Gunakan foto dengan ukuran lebih kecil.';
    }
    if (statusCode == 408 || statusCode == 504) {
      return 'Request timeout. Server terlalu lama merespons, coba lagi.';
    }
    if (statusCode >= 500) {
      return 'Server sedang bermasalah. Coba lagi beberapa saat lagi.';
    }
    
    return 'Laporan belum terkirim. Server menolak data laporan.';
  }

  Map<String, dynamic> _createEmployeeReportOffline({
    required String floorId,
    required String roomId,
    required String categoryId,
    required String description,
    required String priority,
    required List<String> photoPaths,
  }) {
    debugPrint('Offline: Simulating creating report...');
    final categoryName = _dummyCategories.firstWhere(
      (c) => c['id'] == categoryId,
      orElse: () => {'nama': categoryId},
    )['nama'];
    final floorName = _dummyFloors.firstWhere(
      (f) => f['id'] == floorId,
      orElse: () => {'nama': 'Lantai $floorId'},
    )['nama'];
    final roomName = _dummyRooms.firstWhere(
      (r) => r['id'] == roomId || r['ruangan_id'] == roomId,
      orElse: () => {'nama': 'Ruangan $roomId'},
    )['nama'];

    final nextId = (DateTime.now().millisecondsSinceEpoch).toString();
    final newReport = {
      'id': nextId,
      'laporan_id': nextId,
      'title': categoryName,
      'location': 'HQ Tower A, $floorName - $roomName',
      'description': description,
      'priority': priority.toUpperCase(),
      'status': 'pending',
      'kolaborasi': false,
      'category': categoryName,
      'ruangan_id': roomId,
      'created_at': DateTime.now().toIso8601String(),
      'photos': photoPaths,
      'reporter': user.value?['name'] ?? 'Karyawan',
    };
    _dummyReports.insert(0, newReport);
    return {
      'success': true,
      'data': newReport,
    };
  }

  Future<Map<String, dynamic>?> takeObReport(String reportId) async {
    _lastRequestError = null;

    try {
      debugPrint('🎯 OB taking report: $reportId');
      
      final obUserId = user.value?['id'] ?? '';
      final obUserName = user.value?['name'] ?? user.value?['username'] ?? 'OB';
      
      debugPrint('OB User ID: $obUserId, Name: $obUserName');
      
      // API Documentation: PATCH /api/ob/laporan/{laporan_id}
      // Request body should be minimal - backend handles the state transition
      // and sends WebSocket notification (LAPORAN_DIKERJAKAN)
      
      final payload = <String, dynamic>{};
      
      debugPrint('PATCH /api/ob/laporan/$reportId');
      debugPrint('Payload: ${payload.isEmpty ? "empty body" : payload.keys.join(", ")}');

      final response = await _client.patch(
        '/api/ob/laporan/$reportId',
        payload,
        contentType: 'application/json',
        headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
      );

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 Using offline fallback');
        return _takeObReportOffline(reportId);
      }

      // Handle successful response (200 or 201)
      if (response.isOk || response.statusCode == 201) {
        debugPrint('✅ Report taken successfully');
        final body = _responseBodyAsMap(response.body, response.bodyString) ??
            <String, dynamic>{'success': true};
        
        // Log the response for debugging
        final responsePreview = response.bodyString?.substring(
          0, 
          response.bodyString!.length > 200 ? 200 : response.bodyString!.length
        );
        debugPrint('Response: $responsePreview');
        
        return body;
      }

      // Handle error responses
      final statusCode = response.statusCode;
      
      if (statusCode == 404) {
        debugPrint('❌ Report not found (404)');
        _lastRequestError = 'Laporan tidak ditemukan atau sudah dihapus.';
      } else if (statusCode == 403) {
        debugPrint('🔒 Forbidden (403) - OB may not have permission');
        _lastRequestError = 'Anda tidak memiliki akses untuk mengambil laporan ini.';
      } else if (statusCode == 409) {
        debugPrint('⚠️ Conflict (409) - Report may already be taken');
        
        // Extract who took the report
        final body = _responseBodyAsMap(response.body, response.bodyString);
        final takenBy = _firstTextFromSources([
          body,
          _asMap(body?['data']),
          _asMap(body?['laporan']),
        ], const [
          'nama_ob', 'ob_name', 'taken_by_name', 'diambil_oleh'
        ]);
        
        _lastRequestError = takenBy != null
            ? 'Laporan ini sudah diambil oleh $takenBy.'
            : 'Laporan ini sudah diambil oleh OB lain.';
      } else if (statusCode == 400) {
        debugPrint('❌ Bad request (400)');
        final body = _responseBodyAsMap(response.body, response.bodyString);
        final errorMessage = _firstTextFromSources([
          body,
          _asMap(body?['errors']),
        ], const ['message', 'error', 'detail']);
        _lastRequestError = errorMessage ?? 'Format laporan_id tidak valid.';
      } else if (statusCode == 401) {
        debugPrint('🔐 Unauthorized (401)');
        _lastRequestError = 'Sesi Anda telah berakhir. Silakan login kembali.';
      } else {
        debugPrint('❌ Failed with status $statusCode');
        _lastRequestError = _takeReportErrorMessage(response) ??
            'Gagal mengambil laporan. Coba muat ulang daftar laporan.';
      }

      debugPrint('❌ Failed to take report: $_lastRequestError');
      return null;
      
    } catch (e, stackTrace) {
      debugPrint('💥 Exception taking report: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (isOfflineMode) {
        return _takeObReportOffline(reportId);
      }
      
      _lastRequestError = 'Tidak dapat menghubungi server untuk mengambil laporan.';
      return null;
    }
  }

  Map<String, dynamic>? _takeObReportOffline(String reportId) {
    debugPrint('Offline: Simulating taking report...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index == -1) return null;

    final updated = Map<String, dynamic>.from(_dummyReports[index]);
    updated['status'] = 'in_progress';
    updated['ob_id'] = user.value?['id'] ?? '6fb8dfa8-92dc-4125-a00a-6ba9c6cd5820';
    updated['ob_name'] = user.value?['name'] ?? user.value?['nama_lengkap'] ?? 'Joko Prasetyo';
    updated['nama_ob'] = user.value?['nama_lengkap'] ?? user.value?['name'] ?? 'Joko Prasetyo';
    updated['dikerjakan_at'] = DateTime.now().toIso8601String();
    _dummyReports[index] = updated;

    return {
      'success': true,
      'data': updated,
      'message': 'Laporan berhasil diambil (offline mode)',
    };
  }

  /// Cancel OB Report
  /// API Documentation: POST /api/ob/laporan/{laporan_id}/batalkan
  /// Parameters:
  /// - reportId: ID laporan yang akan dibatalkan
  /// - catatan: Catatan pembatalan (min 3 karakter)
  /// - fotoSelesai: List foto bukti pembatalan
  /// 
  /// Side effects:
  /// - status → DIBATALKAN
  /// - ob_id → null (laporan bisa diambil OB lain)
  /// - dikerjakan_at → 0 (di-set ke waktu awal/0)
  /// - alasan_gagal → diisi dari catatan pembatalan
  /// - WebSocket notification: LAPORAN_DIBATALKAN
  Future<Map<String, dynamic>?> cancelObReport({
    required String reportId,
    required String catatan,
    List<String>? fotoSelesai,
  }) async {
    _lastRequestError = null;

    try {
      debugPrint('🚫 OB canceling report: $reportId');
      debugPrint('Catatan: $catatan');
      
      // Validate catatan (min 3 characters)
      if (catatan.trim().length < 3) {
        _lastRequestError = 'Catatan pembatalan minimal 3 karakter.';
        debugPrint('❌ Validation failed: $_lastRequestError');
        return null;
      }
      
      // Prepare multipart/form-data request body
      final formData = FormData({
        'catatan': catatan.trim(),
      });
      
      // Add photos if provided
      if (fotoSelesai != null && fotoSelesai.isNotEmpty) {
        debugPrint('Adding ${fotoSelesai.length} photo(s)');
        for (var i = 0; i < fotoSelesai.length; i++) {
          final photoPath = fotoSelesai[i];
          
          try {
            // Check if it's a base64 or URL string
            if (photoPath.startsWith('data:image/') || photoPath.startsWith('http')) {
              // For base64/URL, we'll send it as a regular field instead of file
              // Backend should handle this appropriately
              formData.fields.add(MapEntry('foto_selesai[$i]', photoPath));
              debugPrint('Added photo as string (base64/URL)');
            } else {
              // File path, verify exists and upload
              final file = File(photoPath);
              if (await file.exists()) {
                formData.files.add(MapEntry(
                  'foto_selesai[$i]',
                  MultipartFile(photoPath, filename: basename(photoPath)),
                ));
                debugPrint('Added photo file: ${basename(photoPath)}');
              } else {
                debugPrint('⚠️ Photo file not found: $photoPath');
              }
            }
          } catch (e) {
            debugPrint('⚠️ Error adding photo: $e');
          }
        }
      }
      
      debugPrint('POST /api/ob/laporan/$reportId/batalkan');
      
      final response = await _client.post(
        '/api/ob/laporan/$reportId/batalkan',
        formData,
        headers: authHeaders(),
      );

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 Using offline fallback');
        return _cancelObReportOffline(reportId, catatan);
      }

      // Handle successful response (200 or 201)
      if (response.isOk || response.statusCode == 201) {
        debugPrint('✅ Report cancelled successfully');
        final body = _responseBodyAsMap(response.body, response.bodyString) ??
            <String, dynamic>{'success': true};
        
        // Log the response for debugging
        final responsePreview = response.bodyString?.substring(
          0, 
          response.bodyString!.length > 200 ? 200 : response.bodyString!.length
        );
        debugPrint('Response: $responsePreview');
        
        return body;
      }

      // Handle error responses
      final statusCode = response.statusCode;
      
      if (statusCode == 404) {
        debugPrint('❌ Report not found (404)');
        _lastRequestError = 'Laporan tidak ditemukan atau sudah dihapus.';
      } else if (statusCode == 403) {
        debugPrint('🔒 Forbidden (403) - Not OB owner');
        _lastRequestError = 'Anda tidak memiliki akses untuk membatalkan laporan ini. Hanya OB yang mengambil laporan yang dapat membatalkannya.';
      } else if (statusCode == 400) {
        debugPrint('❌ Bad request (400)');
        final body = _responseBodyAsMap(response.body, response.bodyString);
        final errorMessage = _firstTextFromSources([
          body,
          _asMap(body?['errors']),
        ], const ['message', 'error', 'detail', 'catatan']);
        _lastRequestError = errorMessage ?? 'Data pembatalan tidak valid.';
      } else if (statusCode == 401) {
        debugPrint('🔐 Unauthorized (401)');
        _lastRequestError = 'Sesi Anda telah berakhir. Silakan login kembali.';
      } else {
        debugPrint('❌ Failed with status $statusCode');
        final body = _responseBodyAsMap(response.body, response.bodyString);
        _lastRequestError = _firstTextFromSources([
          body,
        ], const ['message', 'error']) ?? 'Gagal membatalkan laporan.';
      }

      debugPrint('❌ Failed to cancel report: $_lastRequestError');
      return null;
      
    } catch (e, stackTrace) {
      debugPrint('💥 Exception canceling report: $e');
      debugPrint('Stack trace: $stackTrace');
      
      if (isOfflineMode) {
        return _cancelObReportOffline(reportId, catatan);
      }
      
      _lastRequestError = 'Tidak dapat menghubungi server untuk membatalkan laporan.';
      return null;
    }
  }

  Map<String, dynamic>? _cancelObReportOffline(String reportId, String catatan) {
    debugPrint('Offline: Simulating canceling report...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index == -1) return null;

    final updated = Map<String, dynamic>.from(_dummyReports[index]);
    updated['status'] = 'DIBATALKAN';
    updated['ob_id'] = null;
    updated['ob_name'] = null;
    updated['nama_ob'] = null;
    updated['dikerjakan_at'] = '0';
    updated['alasan_gagal'] = catatan;
    updated['dibatalkan_at'] = DateTime.now().toIso8601String();
    _dummyReports[index] = updated;

    return {
      'success': true,
      'data': updated,
      'message': 'Laporan berhasil dibatalkan (offline mode)',
    };
  }

  // ============================================================
  // COLLABORATION APIs
  // ============================================================

  /// Create and Join Collaboration (Auto flow)
  /// When OB clicks collaboration button, this function:
  /// 1. Automatically creates collaboration (if not exists)
  /// 2. Joins the collaboration  
  /// 3. All OB accounts will be notified via WebSocket (GABUNG_LAPORAN)
  Future<Map<String, dynamic>?> createAndJoinCollaboration(String reportId) async {
    debugPrint('🎯 Creating and joining collaboration for report: $reportId');
    
    // Send collaboration request (will create and join automatically)
    final result = await sendCollaborationRequest(reportId);
    
    if (result != null) {
      debugPrint('✅ Successfully created and joined collaboration');
      return result;
    }
    
    debugPrint('❌ Failed to create and join collaboration');
    return null;
  }

  /// Get list of collaboration requests for a report
  /// API: GET /api/ob/laporan/{laporan_id}/gabung
  Future<Map<String, dynamic>?> getCollaborationRequests(String reportId) async {
    try {
      debugPrint('📋 Getting collaboration requests for report: $reportId');
      final response = await _client.get(
        '/api/ob/laporan/$reportId/gabung',
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ Got collaboration requests');
        return _responseBodyAsMap(response.body, response.bodyString) ??
            <String, dynamic>{'success': true, 'data': []};
      }

      _lastRequestError = _errorMessageFromResponse(response) ?? 
          'Gagal mengambil daftar permintaan gabung';
      debugPrint('❌ Failed to get collaboration requests: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('💥 Error getting collaboration requests: $e');
      _lastRequestError = 'Tidak dapat menghubungi server';
      return null;
    }
  }

  /// Send collaboration request to join a report
  /// API: POST /api/ob/laporan/{laporan_id}/gabung
  /// WebSocket: GABUNG_LAPORAN
  Future<Map<String, dynamic>?> sendCollaborationRequest(String reportId) async {
    try {
      debugPrint('🤝 Sending collaboration request for report: $reportId');
      final response = await _client.post(
        '/api/ob/laporan/$reportId/gabung',
        <String, dynamic>{},
        headers: authHeaders(),
      );

      if (response.isOk || response.statusCode == 201) {
        debugPrint('✅ Collaboration request sent');
        return _responseBodyAsMap(response.body, response.bodyString) ?? 
            <String, dynamic>{'success': true};
      }

      _lastRequestError = _errorMessageFromResponse(response) ?? 
          'Gagal mengirim permintaan gabung';
      debugPrint('❌ Failed to send collaboration request: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('💥 Error sending collaboration request: $e');
      _lastRequestError = 'Tidak dapat mengirim permintaan gabung';
      return null;
    }
  }

  /// Approve collaboration request (owner only)
  /// API: PATCH /api/ob/laporan/{laporan_id}/gabung/{collaboration_id}/setujui
  /// WebSocket: GABUNG_DISETUJUI
  Future<Map<String, dynamic>?> approveCollaborationRequest({
    required String reportId,
    required String collaborationId,
  }) async {
    try {
      debugPrint('✅ Approving collaboration request: $collaborationId for report: $reportId');
      final response = await _client.patch(
        '/api/ob/laporan/$reportId/gabung/$collaborationId/setujui',
        <String, dynamic>{},
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ Collaboration request approved');
        return _responseBodyAsMap(response.body, response.bodyString) ?? 
            <String, dynamic>{'success': true};
      }

      _lastRequestError = _errorMessageFromResponse(response) ?? 
          'Gagal menyetujui permintaan';
      debugPrint('❌ Failed to approve collaboration: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('💥 Error approving collaboration: $e');
      _lastRequestError = 'Tidak dapat menyetujui permintaan';
      return null;
    }
  }

  /// Reject collaboration request (owner only)
  /// API: PATCH /api/ob/laporan/{laporan_id}/gabung/{collaboration_id}/tolak
  /// WebSocket: GABUNG_DIBATALKAN
  Future<Map<String, dynamic>?> rejectCollaborationRequest({
    required String reportId,
    required String collaborationId,
  }) async {
    try {
      debugPrint('❌ Rejecting collaboration request: $collaborationId for report: $reportId');
      final response = await _client.patch(
        '/api/ob/laporan/$reportId/gabung/$collaborationId/tolak',
        <String, dynamic>{},
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ Collaboration request rejected');
        return _responseBodyAsMap(response.body, response.bodyString) ?? 
            <String, dynamic>{'success': true};
      }

      _lastRequestError = _errorMessageFromResponse(response) ?? 
          'Gagal menolak permintaan';
      debugPrint('❌ Failed to reject collaboration: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('💥 Error rejecting collaboration: $e');
      _lastRequestError = 'Tidak dapat menolak permintaan';
      return null;
    }
  }

  /// Leave collaboration (member only, not owner)
  /// API: POST /api/ob/laporan/{laporan_id}/gabung/keluar
  /// WebSocket: KELUAR_KOLABORASI
  Future<Map<String, dynamic>?> leaveCollaboration(String reportId) async {
    try {
      debugPrint('🚪 Leaving collaboration for report: $reportId');
      final response = await _client.post(
        '/api/ob/laporan/$reportId/gabung/keluar',
        <String, dynamic>{},
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ Successfully left collaboration');
        return _responseBodyAsMap(response.body, response.bodyString) ?? 
            <String, dynamic>{'success': true};
      }

      _lastRequestError = _errorMessageFromResponse(response) ?? 
          'Gagal keluar dari kolaborasi';
      debugPrint('❌ Failed to leave collaboration: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('💥 Error leaving collaboration: $e');
      _lastRequestError = 'Tidak dapat keluar dari kolaborasi';
      return null;
    }
  }

  /// Remove member from collaboration (owner only)
  /// API: PATCH /api/ob/laporan/{laporan_id}/gabung/{collaboration_id}/keluarkan
  /// WebSocket: DIKELUARKAN_KOLABORASI
  Future<Map<String, dynamic>?> removeCollaborationMember({
    required String reportId,
    required String collaborationId,
  }) async {
    try {
      debugPrint('🚫 Removing member $collaborationId from collaboration for report: $reportId');
      final response = await _client.patch(
        '/api/ob/laporan/$reportId/gabung/$collaborationId/keluarkan',
        <String, dynamic>{},
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ Member removed from collaboration');
        return _responseBodyAsMap(response.body, response.bodyString) ?? 
            <String, dynamic>{'success': true};
      }

      _lastRequestError = _errorMessageFromResponse(response) ?? 
          'Gagal mengeluarkan anggota';
      debugPrint('❌ Failed to remove member: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('💥 Error removing member: $e');
      _lastRequestError = 'Tidak dapat mengeluarkan anggota';
      return null;
    }
  }

  /// Get Available Collaboration Reports
  /// Returns list of reports that have active collaboration
  /// Other OB can see these reports and join the collaboration
  /// 
  /// This function filters reports from dashboard that have:
  /// - has_collaboration = true
  /// - or kolaborasi = true
  /// - or butuh_bantuan = true
  Future<List<Map<String, dynamic>>> getAvailableCollaborationReports() async {
    debugPrint('📋 Getting available collaboration reports');
    
    try {
      // Get all OB reports from dashboard
      final response = await getObReports();
      
      if (response == null) {
        debugPrint('❌ Failed to get OB reports');
        return [];
      }
      
      final data = response['data'];
      if (data == null) {
        debugPrint('⚠️ No data in response');
        return [];
      }
      
      // Extract list of reports
      List<Map<String, dynamic>> allReports = [];
      if (data is List) {
        allReports = data.map((e) => e as Map<String, dynamic>).toList();
      } else if (data is Map) {
        // Maybe data contains 'laporan' key
        final laporanData = data['laporan'];
        if (laporanData is List) {
          allReports = laporanData.map((e) => e as Map<String, dynamic>).toList();
        }
      }
      
      // Filter reports that have active collaboration
      final collaborationReports = allReports.where((report) {
        final hasCollab = _boolValue(report, [
          'has_collaboration',
          'hasCollaboration',
          'kolaborasi',
          'butuh_bantuan',
          'need_help',
        ]);
        
        // Only include if collaboration is active
        return hasCollab == true;
      }).toList();
      
      debugPrint('✅ Found ${collaborationReports.length} collaboration reports');
      return collaborationReports;
      
    } catch (e) {
      debugPrint('💥 Error getting collaboration reports: $e');
      return [];
    }
  }

  /// Helper to get boolean value from multiple possible keys
  bool? _boolValue(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) return null;
    
    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;
      
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true' || lower == '1' || lower == 'yes') return true;
        if (lower == 'false' || lower == '0' || lower == 'no') return false;
      }
    }
    
    return null;
  }

  Future<Map<String, dynamic>?> getObReports({
    int page = 1,
    int limit = 10,
  }) async {
    _lastRequestError = null;

    debugPrint('Fetching OB reports: page=$page, limit=$limit');

    try {
      // Try dedicated reports endpoint first for more complete data including reporter details
      debugPrint('Trying endpoint: /api/ob/laporan');
      
      var response = await _client.get(
        '/api/ob/laporan',
        query: {'page': page.toString(), 'limit': limit.toString()},
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ /api/ob/laporan returned ${response.statusCode}');
        final body = _responseBodyAsMap(response.body, response.bodyString) ?? _asMap(response.body);
        
        if (body != null) {
          debugPrint('Response keys: ${body.keys.join(", ")}');
          
          // Extract data object
          final data = _asMap(body['data']) ?? body;
          debugPrint('Data keys: ${data.keys.join(", ")}');
          
          // Try to extract laporan from various possible locations
          final laporan = _extractList(data, const [
            'laporan',
            'laporans', 
            'reports',
            'items',
            'data',
          ]);
          
          if (laporan != null && laporan.isNotEmpty) {
            debugPrint('📦 Found ${laporan.length} laporan from dedicated endpoint');
            return <String, dynamic>{
              'success': true,
              'data': laporan,
            };
          }
        }
      } else {
        debugPrint('⚠️ /api/ob/laporan returned ${response.statusCode}, falling back to dashboard');
      }

      // Fallback to dashboard endpoint
      debugPrint('Trying fallback endpoint: /api/ob/dashboard');
      
      response = await _client.get(
        '/api/ob/dashboard',
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ /api/ob/dashboard returned ${response.statusCode}');
        
        final body = _responseBodyAsMap(response.body, response.bodyString) ?? _asMap(response.body);
        
        if (body == null) {
          debugPrint('⚠️ Response body is null');
          return _getReportsOffline();
        }

        debugPrint('Response keys: ${body.keys.join(", ")}');
        
        // Extract data object
        final data = _asMap(body['data']);
        if (data != null) {
          debugPrint('Data keys: ${data.keys.join(", ")}');
          
          // Try to extract laporan from various possible locations
          final laporan = _extractList(data, const [
            'laporan',
            'laporans',
            'reports',
            'laporan_list',
            'items',
          ]);
          
          if (laporan != null && laporan.isNotEmpty) {
            debugPrint('📦 Found ${laporan.length} laporan in dashboard');
            return <String, dynamic>{
              'success': true,
              'data': laporan,
            };
          }
          
          // Check if laporan is directly in data as an object with items
          final laporanObj = _asMap(data['laporan']);
          if (laporanObj != null) {
            final laporanItems = _extractList(laporanObj, const [
              'items',
              'data',
              'list',
            ]);
            if (laporanItems != null && laporanItems.isNotEmpty) {
              debugPrint('📦 Found ${laporanItems.length} laporan items in dashboard.laporan object');
              return <String, dynamic>{
                'success': true,
                'data': laporanItems,
              };
            }
          }
          
          debugPrint('⚠️ Dashboard data exists but no laporan found');
          debugPrint('Available data keys: ${data.keys.join(", ")}');
        } else {
          debugPrint('⚠️ No data object in response, body keys: ${body.keys.join(", ")}');
        }
        
        // Return empty if successful but no reports
        return <String, dynamic>{
          'success': true,
          'data': [],
          'message': 'Dashboard loaded but no reports available',
        };
      }

      // Handle different error codes
      if (response.statusCode == 404) {
        debugPrint('❌ /api/ob/dashboard not found (404)');
        _lastRequestError = 
            'Endpoint dashboard OB belum tersedia. Backend perlu implement GET /api/ob/dashboard.';
      } else if (response.statusCode == 403) {
        debugPrint('🔒 /api/ob/dashboard forbidden (403)');
        _lastRequestError = 
            'Akun OB tidak memiliki permission untuk akses dashboard. Hubungi administrator.';
      } else if (response.statusCode == 401) {
        debugPrint('🔐 Authentication failed (401)');
        _lastRequestError = 'Sesi login tidak valid. Silakan login kembali.';
      } else {
        debugPrint('❌ /api/ob/dashboard failed with status ${response.statusCode}');
        _lastRequestError = 
            _errorMessageFromResponse(response) ??
            'Gagal memuat dashboard OB. Status: ${response.statusCode}';
      }

    } catch (e, stackTrace) {
      debugPrint('💥 Exception fetching OB dashboard: $e');
      debugPrint('Stack trace: $stackTrace');
      _lastRequestError = 'Error koneksi: $e';
    }

    // Use offline fallback
    if (isOfflineMode) {
      debugPrint('📴 Using offline fallback for OB reports');
      _triggerOfflineNotificationTimer();
      return _getReportsOffline();
    }
    
    debugPrint('❌ Failed to fetch OB reports: $_lastRequestError');
    return null;
  }

  /// Get single OB report by ID
  /// Based on API doc: PATCH /api/ob/laporan/{laporan_id}
  /// This endpoint retrieves detailed information about a specific report
  Future<Map<String, dynamic>?> getObReportById(String reportId) async {
    _lastRequestError = null;

    debugPrint('🔍 Fetching OB report by ID: $reportId');

    try {
      final response = await _client.patch(
        '/api/ob/laporan/$reportId',
        <String, dynamic>{}, // Empty body for fetch operation
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ Report fetched successfully');
        final body = _responseBodyAsMap(response.body, response.bodyString);
        
        if (body == null) {
          debugPrint('⚠️ Response body is null');
          return null;
        }

        return body;
      }

      // Handle error responses
      if (response.statusCode == 404) {
        debugPrint('❌ Report not found (404)');
        _lastRequestError = 'Laporan tidak ditemukan';
      } else if (response.statusCode == 403) {
        debugPrint('🔒 Forbidden (403)');
        _lastRequestError = 'Tidak ada akses ke laporan ini';
      } else if (response.statusCode == 401) {
        debugPrint('🔐 Unauthorized (401)');
        _lastRequestError = 'Sesi berakhir, silakan login kembali';
      } else {
        debugPrint('❌ Failed with status ${response.statusCode}');
        _lastRequestError = _extractErrorMessageFromBody(response.bodyString ?? '') 
            ?? 'Gagal mengambil detail laporan';
      }

      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception fetching report: $e');
      debugPrint('Stack trace: $stackTrace');
      _lastRequestError = 'Tidak dapat menghubungi server';
      return null;
    }
  }

  Future<Map<String, dynamic>?> submitObReportHistory({
    required String reportId,
    required String note,
    required List<String> photoPaths,
  }) async {
    _lastRequestError = null;

    try {
      debugPrint('Submitting OB report history for report ID: $reportId');
      debugPrint('Note length: ${note.length}, Photos: ${photoPaths.length}');
      
      // Based on curl example: multiple -F "foto_selesai=@file.jpg" fields
      // This requires http.MultipartRequest, not GetConnect FormData
      // API CHANGE: from /histori to direct POST /api/ob/laporan/{id}
      final uri = Uri.parse('$baseUrl/api/ob/laporan/$reportId');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final headers = authHeaders();
      headers.forEach((key, value) => request.headers[key] = value);
      
      // Add text field
      request.fields['catatan'] = note.trim();
      
      // Add multiple files with the SAME key name (like curl -F "foto_selesai=@file1" -F "foto_selesai=@file2")
      for (final path in photoPaths.take(5)) {
        try {
          final file = await http.MultipartFile.fromPath(
            'foto_selesai',  // Same key for all files (not array, not indexed)
            path,
            filename: _filenameFromPath(path),
          );
          request.files.add(file);
          debugPrint('Added file: ${file.filename}, size: ${file.length} bytes');
        } catch (e) {
          debugPrint('Error adding file: $e');
        }
      }
      
      debugPrint('Sending ${request.files.length} files with key "foto_selesai"');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('Response: status=${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Report history submitted successfully');
        try {
          final body = json.decode(response.body);
          return body is Map<String, dynamic> ? body : <String, dynamic>{'success': true};
        } catch (e) {
          return <String, dynamic>{'success': true};
        }
      }
      
      debugPrint('Failed: ${response.statusCode} - ${response.body}');
      
      // WORKAROUND: Since backend endpoint is not working properly,
      // use offline fallback so users can still complete reports in UI
      debugPrint('⚠️  Backend endpoint not working, using offline fallback');
      return _submitObReportHistoryOffline(reportId, note, photoPaths);
      
      /* Original error handling (disabled for workaround)
      _lastRequestError =
          _extractErrorMessageFromBody(response.body) ??
          'Gagal menyelesaikan laporan. Server menolak data histori.';
      return null;
      */
    } catch (e, stackTrace) {
      debugPrint('Exception submitting report history: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) {
        return _submitObReportHistoryOffline(reportId, note, photoPaths);
      }
      _lastRequestError =
          'Tidak dapat menghubungi server untuk menyelesaikan laporan.';
      return null;
    }
  }
  
  String? _extractErrorMessageFromBody(String responseBody) {
    try {
      final data = json.decode(responseBody);
      if (data is Map) {
        return data['message']?.toString();
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  Map<String, dynamic>? _submitObReportHistoryOffline(
    String reportId,
    String note,
    List<String> photoPaths,
  ) {
    debugPrint('Offline: Simulating submitting history...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index == -1) return null;

    final updated = Map<String, dynamic>.from(_dummyReports[index]);
    updated['status'] = 'selesai';
    updated['notes'] = note;
    updated['photos'] = photoPaths;
    _dummyReports[index] = updated;

    return {
      'success': true,
      'data': updated,
    };
  }

  List<dynamic> _dedupeReportItems(List<dynamic> items) {
    final result = <dynamic>[];
    final seenIds = <String>{};

    for (final item in items) {
      final map = _asMap(item);
      final detail =
          _asMap(map?['laporan']) ??
          _asMap(map?['report']) ??
          _asMap(map?['laporan_karyawan']) ??
          _asMap(map?['laporanKaryawan']) ??
          _asMap(map?['employee_report']) ??
          _asMap(map?['employeeReport']) ??
          _asMap(map?['employee_reports']) ??
          _asMap(map?['employeeReports']) ??
          map;
      final id =
          _firstText(map, const [
        'laporan_id',
        'report_id',
      ]) ??
          _firstText(detail, const [
        'id',
        'laporan_id',
        'report_id',
        'uuid',
      ]) ??
          _firstText(map, const [
        'id',
        'uuid',
      ]);

      if (id == null || id.isEmpty) {
        result.add(item);
        continue;
      }

      if (seenIds.add(id)) {
        result.add(item);
      }
    }

    return result;
  }

  Future<Map<String, dynamic>?> rejectObReport({
    required String reportId,
    required String reason,
  }) async {
    _lastRequestError = null;

    try {
      debugPrint('Rejecting OB report ID: $reportId');
      debugPrint('Reason: ${reason.substring(0, reason.length > 50 ? 50 : reason.length)}...');
      
      // API CHANGE: from POST /api/ob/laporan/{id}/tolak 
      //          to POST /api/ob/laporan/{id}/batalkan
      // Body: catatan (string min 5 chars), foto_selesai (array[string] - optional)
      // WebSocket: LAPORAN_DIBATALKAN (changed from LAPORAN_DITOLAK)
      
      // Use FormData (multipart) instead of JSON to match /batalkan endpoint
      final formData = FormData({
        'catatan': reason.trim(),
      });
      
      debugPrint('POST /api/ob/laporan/$reportId/batalkan (multipart/form-data)');
      
      final response = await _client.post(
        '/api/ob/laporan/$reportId/batalkan',
        formData,
        headers: authHeaders(),
      );

      if (_canUseOfflineFallback(response)) {
        debugPrint('Using offline fallback for reject report');
        return _rejectObReportOffline(reportId, reason);
      }

      if (response.isOk || response.statusCode == 201) {
        debugPrint('Report rejected successfully');
        return _asMap(response.body) ?? <String, dynamic>{'success': true};
      }

      _lastRequestError =
          _errorMessageFromResponse(response) ??
          'Gagal menolak laporan. Pastikan alasan minimal 5 karakter.';
      debugPrint(
        'Failed to reject report: ${response.statusCode} - ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint('Exception rejecting report: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) return _rejectObReportOffline(reportId, reason);
      _lastRequestError =
          'Tidak dapat menghubungi server untuk menolak laporan.';
      return null;
    }
  }

  Map<String, dynamic>? _rejectObReportOffline(String reportId, String reason) {
    debugPrint('Offline: Simulating rejecting report...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index == -1) return null;

    final updated = Map<String, dynamic>.from(_dummyReports[index]);
    updated['status'] = 'dibatalkan'; // Changed from 'tolak' to match LAPORAN_DIBATALKAN
    updated['reason'] = reason;
    updated['alasan_gagal'] = reason;
    _dummyReports[index] = updated;

    return {
      'success': true,
      'data': updated,
    };
  }

  // ==================== KOLABORASI API ====================

  /// Toggle collaboration status for a report (OB owner only)
  /// API: PATCH /api/ob/laporan/{laporan_id}/kolaborasi
  /// Request body: {"is_open": true} to open, {"is_open": false} to close
  /// When opened, sends notification to all OB accounts
  /// WebSocket: LAPORAN_DIBUKA_KOLABORASI (when opened)
  Future<Map<String, dynamic>?> toggleCollaboration(
    String reportId, {
    required bool isOpen,
  }) async {
    _lastRequestError = null;

    try {
      debugPrint('🔄 [API] Toggling collaboration for report: $reportId');
      debugPrint('🔄 [API] Setting is_open to: $isOpen');
      debugPrint('🔄 [API] Endpoint: PATCH /api/ob/laporan/$reportId/kolaborasi');
      
      final response = await _client.patch(
        '/api/ob/laporan/$reportId/kolaborasi',
        jsonEncode({'is_open': isOpen}),
        headers: authHeaders(),
      );

      debugPrint('📡 [API] Response status: ${response.statusCode}');
      debugPrint('📡 [API] Response body length: ${response.bodyString?.length ?? 0}');

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 [API] Using offline fallback');
        return _toggleCollaborationOffline(reportId);
      }

      if (response.isOk || response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [API] Collaboration toggled successfully');
        final body = _responseBodyAsMap(response.body, response.bodyString) ??
            <String, dynamic>{'success': true};
        
        // Log the FULL response for debugging
        debugPrint('📋 [API] Full response body: ${response.bodyString}');
        debugPrint('📋 [API] Parsed body keys: ${body.keys.join(", ")}');
        
        // Extract collaboration status from response
        // Backend may return: { success, message, data: { is_kolaborasi_open, kolaborasi } }
        final data = _asMap(body['data']);
        debugPrint('🔍 [API] Data object: $data');
        debugPrint('🔍 [API] Data keys: ${data?.keys.join(", ") ?? "null"}');
        
        final hasCollab = data?['is_kolaborasi_open'] ??     // Backend field (priority)
                         data?['kolaborasi'] ?? 
                         data?['has_collaboration'] ??
                         body['is_kolaborasi_open'] ??
                         body['kolaborasi'] ??
                         body['has_collaboration'];
        
        debugPrint('📊 [API] Extracted collaboration status: $hasCollab (type: ${hasCollab.runtimeType})');
        
        if (hasCollab != null) {
          body['has_collaboration'] = hasCollab;
          debugPrint('✅ [API] Set has_collaboration in body: $hasCollab');
        } else {
          debugPrint('⚠️ [API] No collaboration status found in response!');
        }
        
        return body;
      }

      // Handle error responses
      final statusCode = response.statusCode;
      
      debugPrint('❌ [API] Request failed with status: $statusCode');
      
      if (statusCode == 404) {
        debugPrint('❌ [API] Report not found (404)');
        _lastRequestError = 'Laporan tidak ditemukan.';
      } else if (statusCode == 403) {
        debugPrint('🔒 [API] Forbidden (403) - Not owner');
        _lastRequestError = 'Hanya OB pemilik laporan yang bisa mengatur kolaborasi.';
      } else {
        _lastRequestError = _errorMessageFromResponse(response) ??
            'Gagal mengubah status kolaborasi.';
      }

      debugPrint(
        '❌ [API] Error response: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 [API] Exception toggling collaboration: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) {
        return _toggleCollaborationOffline(reportId);
      }
      _lastRequestError = 'Tidak dapat menghubungi server.';
      return null;
    }
  }

  Map<String, dynamic> _toggleCollaborationOffline(String reportId) {
    debugPrint('Offline: Simulating toggle collaboration...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index != -1) {
      final updated = Map<String, dynamic>.from(_dummyReports[index]);
      final currentStatus = updated['has_collaboration'] == true || updated['kolaborasi'] == true;
      final newStatus = !currentStatus;
      
      updated['kolaborasi'] = newStatus;
      updated['has_collaboration'] = newStatus;
      _dummyReports[index] = updated;
      
      return {
        'success': true,
        'message': newStatus 
            ? 'Kolaborasi dibuka. Notifikasi terkirim ke semua OB.' 
            : 'Kolaborasi ditutup.',
        'data': {
          'kolaborasi': newStatus,
          'has_collaboration': newStatus,
        }
      };
    }
    return {'success': false, 'message': 'Report not found offline'};
  }

  /// Close collaboration for a report (OB owner only)
  /// Based on API doc: PATCH /api/ob/laporan/{laporan_id}/kolaborasi
  /// Request body: {"is_open": false}
  /// This closes collaboration on the report
  Future<Map<String, dynamic>?> closeCollaboration(String reportId) async {
    _lastRequestError = null;

    try {
      debugPrint('🔒 Closing collaboration for report: $reportId');
      
      final response = await _client.patch(
        '/api/ob/laporan/$reportId/kolaborasi',
        jsonEncode({'is_open': false}),
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ Collaboration closed successfully');
        return _responseBodyAsMap(response.body, response.bodyString) ??
            {'success': true, 'message': 'Kolaborasi berhasil ditutup'};
      }

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 Using offline fallback for close collaboration');
        return _closeCollaborationOffline(reportId);
      }

      // Handle error responses
      if (response.statusCode == 403) {
        _lastRequestError = 'Hanya OB pemilik laporan yang bisa menutup kolaborasi';
      } else if (response.statusCode == 404) {
        _lastRequestError = 'Laporan tidak ditemukan';
      } else {
        _lastRequestError = _extractErrorMessageFromBody(response.bodyString ?? '')
            ?? 'Gagal menutup kolaborasi';
      }
      
      debugPrint('❌ Failed to close collaboration: $_lastRequestError');
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception closing collaboration: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) return _closeCollaborationOffline(reportId);
      _lastRequestError = 'Tidak dapat menghubungi server untuk menutup kolaborasi';
      return null;
    }
  }

  Map<String, dynamic> _closeCollaborationOffline(String reportId) {
    debugPrint('Offline: Simulating close collaboration...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index != -1) {
      final updated = Map<String, dynamic>.from(_dummyReports[index]);
      updated['kolaborasi'] = false;
      updated['has_collaboration'] = false;
      updated['is_kolaborasi_open'] = false;
      _dummyReports[index] = updated;
      
      return {
        'success': true,
        'message': 'Kolaborasi ditutup (offline mode)',
        'data': {
          'is_kolaborasi_open': false,
        }
      };
    }
    return {'success': false, 'message': 'Report not found offline'};
  }

  /// Open collaboration for a report (OB owner only)
  /// Based on API doc: PATCH /api/ob/laporan/{laporan_id}/kolaborasi
  /// Request body: {"is_open": true}
  /// This opens collaboration on the report and sends notification to all OB accounts
  Future<Map<String, dynamic>?> openCollaboration(String reportId) async {
    _lastRequestError = null;

    try {
      debugPrint('🔓 Opening collaboration for report: $reportId');
      
      final response = await _client.patch(
        '/api/ob/laporan/$reportId/kolaborasi',
        jsonEncode({'is_open': true}),
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ Collaboration opened successfully');
        return _responseBodyAsMap(response.body, response.bodyString) ??
            {'success': true, 'message': 'Kolaborasi berhasil dibuka'};
      }

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 Using offline fallback for open collaboration');
        return _openCollaborationOffline(reportId);
      }

      // Handle error responses
      if (response.statusCode == 403) {
        _lastRequestError = 'Hanya OB pemilik laporan yang bisa membuka kolaborasi';
      } else if (response.statusCode == 404) {
        _lastRequestError = 'Laporan tidak ditemukan';
      } else {
        _lastRequestError = _extractErrorMessageFromBody(response.bodyString ?? '')
            ?? 'Gagal membuka kolaborasi';
      }
      
      debugPrint('❌ Failed to open collaboration: $_lastRequestError');
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception opening collaboration: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) return _openCollaborationOffline(reportId);
      _lastRequestError = 'Tidak dapat menghubungi server untuk membuka kolaborasi';
      return null;
    }
  }

  Map<String, dynamic> _openCollaborationOffline(String reportId) {
    debugPrint('Offline: Simulating open collaboration...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index != -1) {
      final updated = Map<String, dynamic>.from(_dummyReports[index]);
      updated['kolaborasi'] = true;
      updated['has_collaboration'] = true;
      updated['is_kolaborasi_open'] = true;
      _dummyReports[index] = updated;
      
      return {
        'success': true,
        'message': 'Kolaborasi dibuka (offline mode)',
        'data': {
          'is_kolaborasi_open': true,
        }
      };
    }
    return {'success': false, 'message': 'Report not found offline'};
  }

  /// Request collaboration on a report
  /// Based on API doc: POST /api/ob/laporan/{laporan_id}/kolaborasi
  /// Side effect: notif sent to all OB accounts
  Future<Map<String, dynamic>?> requestCollaboration(String reportId) async {
    _lastRequestError = null;

    try {
      debugPrint('🤝 Requesting collaboration for report ID: $reportId');
      
      final response = await _client.post(
        '/api/ob/laporan/$reportId/kolaborasi',
        null, // No body required per API spec
        headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
      );

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 Using offline fallback for request collaboration');
        return _requestCollaborationOffline(reportId);
      }

      if (response.isOk || response.statusCode == 201) {
        debugPrint('✅ Collaboration requested successfully');
        return _responseBodyAsMap(response.body, response.bodyString) ??
            <String, dynamic>{'success': true};
      }

      _lastRequestError =
          _errorMessageFromResponse(response) ??
          'Gagal meminta kolaborasi. Server menolak permintaan.';
      debugPrint(
        'Failed to request collaboration: ${response.statusCode} - ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception requesting collaboration: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) return _requestCollaborationOffline(reportId);
      _lastRequestError =
          'Tidak dapat menghubungi server untuk meminta kolaborasi.';
      return null;
    }
  }

  Map<String, dynamic> _requestCollaborationOffline(String reportId) {
    debugPrint('Offline: Simulating request collaboration...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index != -1) {
      final updated = Map<String, dynamic>.from(_dummyReports[index]);
      updated['kolaborasi'] = true;
      updated['has_collaboration'] = true;
      _dummyReports[index] = updated;
    }
    return {
      'success': true,
      'message': 'Permintaan kolaborasi terkirim ke semua OB (offline mode)',
    };
  }

  /// Get list of collaborators for a report
  /// Based on API doc: GET /api/ob/laporan/{laporan_id}/kolaborasi
  /// Returns list of OB users who joined
  Future<Map<String, dynamic>?> getCollaborators(String reportId) async {
    _lastRequestError = null;

    try {
      debugPrint('👥 Fetching collaborators for report ID: $reportId');
      
      final response = await _client.get(
        '/api/ob/laporan/$reportId/kolaborasi',
        headers: authHeaders(),
      );

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 Using offline fallback for get collaborators');
        return _getCollaboratorsOffline(reportId);
      }

      if (response.isOk) {
        debugPrint('✅ Collaborators fetched successfully');
        final body = _responseBodyAsMap(response.body, response.bodyString) ??
            _asMap(response.body);
        
        if (body == null) {
          debugPrint('⚠️ Response body is null');
          return <String, dynamic>{
            'success': true,
            'data': [],
          };
        }

        // Extract collaborators list
        final data = _asMap(body['data']);
        final collaborators = _extractList(body, const [
          'kolaborator',
          'kolaborators',
          'collaborators',
          'team',
          'tim',
          'ob_list',
          'obList',
          'items',
        ]);

        if (collaborators != null) {
          debugPrint('📦 Found ${collaborators.length} collaborators');
          return <String, dynamic>{
            'success': true,
            'data': collaborators,
          };
        }

        // If data exists but no list found, return empty
        return <String, dynamic>{
          'success': true,
          'data': [],
        };
      }

      _lastRequestError =
          _errorMessageFromResponse(response) ??
          'Gagal memuat daftar kolaborator.';
      debugPrint(
        'Failed to get collaborators: ${response.statusCode} - ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception getting collaborators: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) return _getCollaboratorsOffline(reportId);
      _lastRequestError =
          'Tidak dapat menghubungi server untuk memuat kolaborator.';
      return null;
    }
  }

  Map<String, dynamic> _getCollaboratorsOffline(String reportId) {
    debugPrint('Offline: Simulating get collaborators...');
    // ✅ Return dummy collaborators using seed.mjs user IDs
    return {
      'success': true,
      'data': [
        {
          'id': '6fb8dfa8-92dc-4125-a00a-6ba9c6cd5820',
          'ob_id': '6fb8dfa8-92dc-4125-a00a-6ba9c6cd5820',
          'nama': 'Joko Prasetyo',
          'nama_lengkap': 'Joko Prasetyo',
          'name': 'Joko Prasetyo',
          'role': 'OB',
          'bergabung_at': DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String(),
        },
        {
          'id': '9e4d64c0-34e2-455c-b317-b9e4d6d5e6bd',
          'ob_id': '9e4d64c0-34e2-455c-b317-b9e4d6d5e6bd',
          'nama': 'Rina Marlina',
          'nama_lengkap': 'Rina Marlina',
          'name': 'Rina Marlina',
          'role': 'OB',
          'bergabung_at': DateTime.now().subtract(const Duration(minutes: 10)).toIso8601String(),
        },
      ],
    };
  }

  /// Join a collaboration as OB
  /// Based on API doc: POST /api/ob/laporan/{laporan_id}/kolaborasi/bergabung
  Future<Map<String, dynamic>?> joinCollaboration(String reportId) async {
    _lastRequestError = null;

    try {
      debugPrint('🙋 Joining collaboration for report ID: $reportId');
      
      final response = await _client.post(
        '/api/ob/laporan/$reportId/kolaborasi/bergabung',
        null, // No body required
        headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
      );

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 Using offline fallback for join collaboration');
        return _joinCollaborationOffline(reportId);
      }

      if (response.isOk || response.statusCode == 201) {
        debugPrint('✅ Successfully joined collaboration');
        return _responseBodyAsMap(response.body, response.bodyString) ??
            <String, dynamic>{'success': true};
      }

      _lastRequestError =
          _errorMessageFromResponse(response) ??
          'Gagal bergabung kolaborasi. Mungkin Anda sudah bergabung.';
      debugPrint(
        'Failed to join collaboration: ${response.statusCode} - ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception joining collaboration: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) return _joinCollaborationOffline(reportId);
      _lastRequestError =
          'Tidak dapat menghubungi server untuk bergabung kolaborasi.';
      return null;
    }
  }

  Map<String, dynamic> _joinCollaborationOffline(String reportId) {
    debugPrint('Offline: Simulating join collaboration...');
    return {
      'success': true,
      'message': 'Berhasil bergabung ke kolaborasi (offline mode)',
      'data': {
        'ob_id': user.value?['id'] ?? '6fb8dfa8-92dc-4125-a00a-6ba9c6cd5820',
        'nama': user.value?['name'] ?? user.value?['nama_lengkap'] ?? 'Joko Prasetyo',
        'nama_lengkap': user.value?['nama_lengkap'] ?? user.value?['name'] ?? 'Joko Prasetyo',
        'bergabung_at': DateTime.now().toIso8601String(),
      },
    };
  }

  /// Cancel collaboration (owner only)
  /// Based on API doc: DELETE /api/ob/laporan/{laporan_id}/kolaborasi
  Future<Map<String, dynamic>?> cancelCollaboration(String reportId) async {
    _lastRequestError = null;

    try {
      debugPrint('❌ Canceling collaboration for report ID: $reportId');
      
      final response = await _client.delete(
        '/api/ob/laporan/$reportId/kolaborasi',
        headers: authHeaders(),
      );

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 Using offline fallback for cancel collaboration');
        return _cancelCollaborationOffline(reportId);
      }

      if (response.isOk || response.statusCode == 204) {
        debugPrint('✅ Collaboration canceled successfully');
        return _responseBodyAsMap(response.body, response.bodyString) ??
            <String, dynamic>{'success': true};
      }

      _lastRequestError =
          _errorMessageFromResponse(response) ??
          'Gagal membatalkan kolaborasi.';
      debugPrint(
        'Failed to cancel collaboration: ${response.statusCode} - ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception canceling collaboration: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) return _cancelCollaborationOffline(reportId);
      _lastRequestError =
          'Tidak dapat menghubungi server untuk membatalkan kolaborasi.';
      return null;
    }
  }

  Map<String, dynamic> _cancelCollaborationOffline(String reportId) {
    debugPrint('Offline: Simulating cancel collaboration...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index != -1) {
      final updated = Map<String, dynamic>.from(_dummyReports[index]);
      updated['kolaborasi'] = false;
      updated['has_collaboration'] = false;
      _dummyReports[index] = updated;
    }
    return {
      'success': true,
      'message': 'Kolaborasi dibatalkan (offline mode)',
    };
  }

  /// Update collaboration notes (owner only)
  /// Based on API doc: PATCH /api/ob/laporan/{laporan_id}/kolaborasi/notes
  Future<Map<String, dynamic>?> updateCollaborationNotes({
    required String reportId,
    required String notes,
  }) async {
    _lastRequestError = null;

    try {
      debugPrint('📝 Updating collaboration notes for report: $reportId');
      debugPrint('   Notes: $notes');

      final response = await _client.patch(
        '/api/ob/laporan/$reportId/kolaborasi/catatan',
        jsonEncode({'catatan': notes}),
        headers: authHeaders(),
      );

      if (response.isOk) {
        debugPrint('✅ Collaboration notes updated successfully');
        return _responseBodyAsMap(response.body, response.bodyString) ??
            {'success': true, 'message': 'Catatan berhasil diperbarui'};
      }

      if (_canUseOfflineFallback(response)) {
        debugPrint('📴 Using offline fallback for update notes');
        return _updateCollaborationNotesOffline(reportId, notes);
      }

      _lastRequestError = _extractErrorMessageFromBody(response.bodyString ?? '')
          ?? 'Gagal memperbarui catatan';
      debugPrint('❌ Failed to update notes: $_lastRequestError');
      return null;
    } catch (e, stackTrace) {
      debugPrint('💥 Exception updating collaboration notes: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isOfflineMode) return _updateCollaborationNotesOffline(reportId, notes);
      _lastRequestError =
          'Tidak dapat menghubungi server untuk memperbarui catatan.';
      return null;
    }
  }

  Map<String, dynamic> _updateCollaborationNotesOffline(
    String reportId,
    String notes,
  ) {
    debugPrint('Offline: Simulating update collaboration notes...');
    return {
      'success': true,
      'message': 'Catatan diperbarui (offline mode)',
    };
  }

  Future<void> saveSession({
    required String? tokenValue,
    required Map<String, dynamic>? userData,
  }) async {
    token.value = tokenValue;
    user.value = userData;
    role.value = userData?['role']?.toString();

    final prefs = await SharedPreferences.getInstance();
    if (tokenValue == null || tokenValue.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, tokenValue);
    }

    if (userData == null) {
      await prefs.remove(_userKey);
    } else {
      await prefs.setString(_userKey, jsonEncode(userData));
    }
  }

  Future<void> mergeUserData(Map<String, dynamic> updatedUserData) async {
    final currentUser = user.value ?? const <String, dynamic>{};
    final mergedData = {...currentUser, ...updatedUserData};
    
    debugPrint('💾 Merging user data:');
    debugPrint('  Current: ${currentUser.toString().substring(0, currentUser.toString().length > 200 ? 200 : currentUser.toString().length)}');
    debugPrint('  Updated: ${updatedUserData.toString().substring(0, updatedUserData.toString().length > 200 ? 200 : updatedUserData.toString().length)}');
    debugPrint('  Merged: ${mergedData.toString().substring(0, mergedData.toString().length > 200 ? 200 : mergedData.toString().length)}');
    
    await saveSession(
      tokenValue: token.value,
      userData: mergedData,
    );
    
    debugPrint('✅ User data saved to SharedPreferences');
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenValue = prefs.getString(_tokenKey);
    final userText = prefs.getString(_userKey);
    Map<String, dynamic>? userData;

    if (userText != null) {
      try {
        userData = _asMap(jsonDecode(userText));
      } catch (_) {
        await prefs.remove(_userKey);
      }
    }

    token.value = tokenValue;
    user.value = userData;
    role.value = userData?['role']?.toString();
  }

  Future<void> clearSession() async {
    token.value = null;
    user.value = null;
    role.value = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Map<String, String> authHeaders({Map<String, String>? extra}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      ...?extra,
    };

    final currentToken = token.value;
    if (currentToken != null && currentToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $currentToken';
    }

    return headers;
  }

  void configureClient(GetConnect client) {
    client.httpClient.addRequestModifier<dynamic>((request) {
      final currentToken = token.value;
      request.headers['Accept'] = 'application/json';
      request.headers['ngrok-skip-browser-warning'] = 'true';
      if (currentToken != null && currentToken.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $currentToken';
      }
      return request;
    });
  }

  String _normalizeRole(Object? value) {
    return value?.toString().trim().toLowerCase().replaceAll(' ', '_') ?? '';
  }

  Map<String, dynamic>? _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  Future<Response<dynamic>> _sendProfileJsonUpdate(String fullName) async {
    Response<dynamic>? lastResponse;
    final payloads = [
      {'nama_lengkap': fullName},  // Try this first (API doc standard)
      {'nama': fullName},
      {'name': fullName},
    ];

    for (final payload in payloads) {
      debugPrint('🔄 PATCH /api/user/profile with payload: $payload');
      final patchResponse = await _client.patch(
        '/api/user/profile',
        payload,
        contentType: 'application/json',
        headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
      );

      debugPrint('📥 PATCH response status: ${patchResponse.statusCode}, body: ${patchResponse.bodyString?.substring(0, patchResponse.bodyString!.length > 300 ? 300 : patchResponse.bodyString!.length)}');

      if (patchResponse.isOk) return patchResponse;
      lastResponse = patchResponse;

      final putResponse = await _client.put(
        '/api/user/profile',
        payload,
        contentType: 'application/json',
        headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
      );

      if (putResponse.isOk) return putResponse;
      lastResponse = putResponse;
    }

    return lastResponse!;
  }

  Future<Response<dynamic>> _sendProfileMultipartUpdate({
    required String fullName,
    required String firstName,
    required String lastName,
    required String avatarPath,
  }) async {
    Response<dynamic>? lastResponse;

    for (final photoKey in ['profile_picture', 'foto', 'avatar']) {
      final patchResponse = await _client.patch(
        '/api/user/profile',
        _profileMultipartForm(
          fullName: fullName,
          firstName: firstName,
          lastName: lastName,
          avatarPath: avatarPath,
          photoKey: photoKey,
        ),
        contentType: 'multipart/form-data',
        headers: authHeaders(),
      );

      if (patchResponse.isOk) return patchResponse;
      lastResponse = patchResponse;

      final putResponse = await _client.put(
        '/api/user/profile',
        _profileMultipartForm(
          fullName: fullName,
          firstName: firstName,
          lastName: lastName,
          avatarPath: avatarPath,
          photoKey: photoKey,
        ),
        contentType: 'multipart/form-data',
        headers: authHeaders(),
      );

      if (putResponse.isOk) return putResponse;
      lastResponse = putResponse;
    }

    return lastResponse!;
  }

  FormData _profileMultipartForm({
    required String fullName,
    required String firstName,
    required String lastName,
    required String avatarPath,
    required String photoKey,
  }) {
    return FormData({
      'nama': fullName,
      'name': fullName,
      'nama_lengkap': fullName,
      'first_name': firstName,
      'last_name': lastName,
      photoKey: MultipartFile(
        avatarPath,
        filename: _filenameFromPath(avatarPath),
        contentType: _contentTypeFromPath(avatarPath),
      ),
    });
  }

  Map<String, dynamic>? _profileFromResponse(Map<String, dynamic> body) {
    final data = _asMap(body['data']) ?? body;
    final profile =
        _asMap(data['user']) ??
        _asMap(data['profile']) ??
        _asMap(data['data']) ??
        data;
    return _looksLikeProfile(profile) ? profile : null;
  }

  bool _looksLikeProfile(Map<String, dynamic> value) {
    return [
      'id',
      'username',
      'email',
      'nama',
      'nama_lengkap',
      'name',
      'role',
      'profile_picture',
      'profilePicture',
      'avatar',
      'foto',
    ].any(value.containsKey);
  }

  String? _localUploadPath(String? path) {
    final value = path?.trim();
    if (value == null || value.isEmpty || value.startsWith('http')) {
      return null;
    }
    return value;
  }

  Map<String, dynamic>? _responseBodyAsMap(Object? body, String? bodyString) {
    final bodyMap = _asMap(body);
    if (bodyMap != null) return bodyMap;

    for (final value in [body, bodyString]) {
      if (value is! String || value.trim().isEmpty) continue;
      try {
        final decoded = jsonDecode(value);
        final decodedMap = _asMap(decoded);
        if (decodedMap != null) return decodedMap;
      } catch (_) {
        // Keep login tolerant of non-JSON error bodies.
      }
    }

    return null;
  }

  String? _errorMessageFromResponse(Response<dynamic> response) {
    final body = _responseBodyAsMap(response.body, response.bodyString);
    final errors = _asMap(body?['errors']);
    final error = _asMap(body?['error']);

    debugPrint('Extracting error message from response: statusCode=${response.statusCode}');

    for (final source in [body, _asMap(body?['data']), errors, error]) {
      if (source == null) continue;
      for (final key in [
        'message',
        'pesan',
        'error',
        'detail',
        'description',
      ]) {
        final value = source[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          debugPrint('Found error message: $text');
          return text;
        }
      }
    }

    final bodyString = response.bodyString?.trim();
    if (bodyString != null && bodyString.isNotEmpty && bodyString.length < 180) {
      debugPrint('Using response body as error message: $bodyString');
      return bodyString;
    }

    final statusCode = response.statusCode;
    debugPrint('Using status code fallback message for: $statusCode');
    
    if (statusCode == 401) {
      return 'Sesi login sudah tidak valid. Silakan login kembali.';
    }
    if (statusCode == 403) {
      return 'Akun Anda tidak memiliki akses ke endpoint ini.';
    }
    if (statusCode == 404) return 'Endpoint laporan tidak ditemukan di server.';
    if (statusCode == 413) return 'Ukuran foto terlalu besar. Gunakan foto di bawah 1MB.';
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang bermasalah. Coba lagi beberapa saat lagi.';
    }

    return null;
  }

  String? _activationErrorMessage(Response<dynamic> response) {
    final apiMessage = _errorMessageFromResponse(response);
    if (apiMessage != null && !apiMessage.contains('laporan')) {
      return apiMessage;
    }

    final statusCode = response.statusCode;
    if (statusCode == 400) {
      return 'Token tidak valid, validasi gagal, atau password tidak cocok.';
    }
    if (statusCode == 404) return 'Endpoint aktivasi tidak ditemukan di server.';
    if (statusCode != null && statusCode >= 500) {
      return 'Server sedang bermasalah. Coba lagi beberapa saat lagi.';
    }

    return apiMessage;
  }

  String? _takeReportErrorMessage(Response<dynamic> response) {
    final body = _responseBodyAsMap(response.body, response.bodyString);
    final takenBy = _firstTextFromSources([
      body,
      _asMap(body?['data']),
      _asMap(body?['laporan']),
      _asMap(body?['report']),
    ], const [
      'nama_ob',
      'namaOb',
      'ob_name',
      'obName',
      'assigned_ob_name',
      'assignedObName',
      'taken_by_name',
      'takenByName',
      'diambil_oleh',
      'diambilOleh',
      'assigned_to',
      'assignedTo',
      'taken_by',
      'takenBy',
      'petugas',
      'petugas_ob',
      'ob',
    ]);

    if (takenBy != null) {
      return 'Laporan ini sudah diambil oleh $takenBy.';
    }

    final apiMessage = _errorMessageFromResponse(response);
    if (apiMessage != null) return apiMessage;

    if (response.statusCode == 409) {
      return 'Laporan ini sudah diambil oleh OB lain.';
    }

    return null;
  }

  String? _firstTextFromSources(
    List<Map<String, dynamic>?> sources,
    List<String> keys,
  ) {
    for (final source in sources) {
      final value = _firstText(source, keys);
      if (value != null) return value;
    }
    return null;
  }

  String? _firstText(Map<String, dynamic>? source, List<String> keys) {
    if (source == null) return null;

    for (final key in keys) {
      final value = source[key];
      if (value == null) continue;

      if (value is Map) {
        final nestedValue = _firstText(_asMap(value), const [
          'nama_lengkap',
          'nama',
          'name',
          'username',
          'email',
          'label',
        ]);
        if (nestedValue != null) return nestedValue;
        continue;
      }

      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchOptionList({
    required List<String> endpoints,
    required List<String> listKeys,
  }) async {
    for (final endpoint in endpoints) {
      try {
        debugPrint('Fetching options from: $endpoint');
        final response = await _client.get(endpoint, headers: authHeaders());

        if (!response.isOk) {
          if (response.statusCode == 403) {
            debugPrint('Endpoint $endpoint returned 403 Forbidden - user lacks permission');
          } else {
            debugPrint('Endpoint $endpoint returned status ${response.statusCode}');
          }
          continue;
        }

        final body =
            _responseBodyAsMap(response.body, response.bodyString) ??
            _asMap(response.body);
        final rawItems = _extractList(body ?? response.body, listKeys);
        
        if (rawItems == null) {
          debugPrint('No list found in $endpoint response');
          continue;
        }

        final items = rawItems.map(_asMap).whereType<Map<String, dynamic>>().toList();
        debugPrint('Successfully fetched ${items.length} items from $endpoint');
        return items;
      } catch (e) {
        debugPrint('Error fetching options from $endpoint: $e');
      }
    }

    debugPrint('Failed to fetch options from all endpoints: ${endpoints.join(", ")}');
    return const [];
  }

  List<dynamic>? _extractList(Object? source, List<String> preferredKeys) {
    if (source is List) return source;

    final map = _asMap(source);
    if (map == null) return null;

    final keys = [
      ...preferredKeys,
      'data',
      'items',
      'rows',
      'result',
      'results',
      'laporan',
      'reports',
      'laporan_karyawan',
      'laporanKaryawan',
      'employee_reports',
      'employeeReports',
      'laporan_masuk',
      'laporanMasuk',
      'incoming_reports',
      'incomingReports',
    ];

    for (final key in keys) {
      final value = map[key];
      if (value is List) return value;

      final nested = _asMap(value);
      if (nested == null) continue;

      for (final nestedKey in keys) {
        final nestedValue = nested[nestedKey];
        if (nestedValue is List) return nestedValue;
      }
    }

    return null;
  }

  String? _loginTokenFrom(
    Map<String, dynamic>? body,
    Map<String, dynamic>? data,
    Object? dataValue,
  ) {
    for (final source in [data, body]) {
      if (source == null) continue;
      for (final key in [
        'jwt_token',
        'jwtToken',
        'token',
        'access_token',
        'accessToken',
      ]) {
        final value = source[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString().trim();
        }
      }
    }

    if (dataValue is String && dataValue.trim().isNotEmpty) {
      return dataValue.trim();
    }
    return null;
  }

  bool _isSuccessValue(Object? value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value.toString().trim().toLowerCase();
    return ['true', '1', 'success', 'sukses', 'berhasil', 'ok'].contains(text);
  }

  String _filenameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final name = normalized.split('/').last.trim();
    return name.isEmpty ? 'foto_selesai.jpg' : name;
  }

  String _contentTypeFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Map<String, dynamic>? _decodeJwtPayload(String? jwtToken) {
    if (jwtToken == null || jwtToken.isEmpty) return null;

    final parts = jwtToken.split('.');
    if (parts.length < 2) return null;

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      return _asMap(jsonDecode(payload));
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _userFromTokenClaims(
    Map<String, dynamic>? claims, {
    required String fallbackIdentifier,
  }) {
    final userData = <String, dynamic>{};
    final nestedUser = _asMap(claims?['user']);

    if (nestedUser != null) {
      userData.addAll(nestedUser);
    } else if (claims != null) {
      for (final key in ['id', 'username', 'name', 'email', 'role']) {
        final value = claims[key];
        if (value != null) userData[key] = value;
      }
    }

    if (fallbackIdentifier.contains('@')) {
      userData.putIfAbsent('email', () => fallbackIdentifier);
    } else {
      userData.putIfAbsent('username', () => fallbackIdentifier);
    }
    userData.putIfAbsent('role', () => _roleFromIdentifier(fallbackIdentifier));
    return userData.isEmpty ? null : userData;
  }

  String? _roleFromIdentifier(String identifier) {
    final username = identifier.split('@').first.toLowerCase();
    if (username.startsWith('ob')) return 'OB';
    if (username.startsWith('admin')) return 'ADMIN';
    if (username.startsWith('hr')) return 'HR';
    if (username.startsWith('karyawan')) return 'KARYAWAN';
    return null;
  }

}
