import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxService {
  static const baseUrl = 'https://stylar-nonseverable-denver.ngrok-free.dev';
  static const _tokenKey = 'token';
  static const _userKey = 'user';

  final token = RxnString();
  final user = Rxn<Map<String, dynamic>>();
  final role = RxnString();
  final _client = GetConnect(timeout: const Duration(seconds: 20));
  String? _lastRequestError;

  // In-memory dummy database for offline fallback
  final List<Map<String, dynamic>> _dummyReports = [
    {
      'id': '1',
      'laporan_id': '1',
      'title': 'Kebocoran Pipa Air',
      'location': 'HQ Tower A, Lantai 4 (Toilet Pria)',
      'description': 'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage.',
      'priority': 'URGENT',
      'status': 'selesai',
      'kolaborasi': true,
      'category': 'Air & Galon',
      'created_at': '2026-07-11T10:00:00.000Z',
      'photos': <String>[],
      'reporter': 'Rahman'
    },
    {
      'id': '2',
      'laporan_id': '2',
      'title': 'Kebocoran Pipa Air',
      'location': 'HQ Tower A, Lantai 4 (Toilet Pria)',
      'description': 'Water pooling near the main vent in hallway B. Requires immediate attention before floor damage.',
      'priority': 'STANDARD',
      'status': 'pending',
      'kolaborasi': false,
      'category': 'Air & Galon',
      'created_at': '2026-07-11T09:00:00.000Z',
      'photos': <String>[],
      'reporter': 'Rahman'
    }
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

  final List<Map<String, dynamic>> _dummyCategories = [
    {
      'id': 'ba7079f3-fc98-4be7-afe3-cc769ffa3458',
      'kategori_id': 'ba7079f3-fc98-4be7-afe3-cc769ffa3458',
      'nama': 'Kebersihan',
      'name': 'Kebersihan',
    },
    {
      'id': 'd2597de5-120f-47b0-878a-83a46c47db34',
      'kategori_id': 'd2597de5-120f-47b0-878a-83a46c47db34',
      'nama': 'Pengecekan',
      'name': 'Pengecekan',
    },
    {
      'id': '5dcba45c-b5de-437c-858b-50dbe7624f9b',
      'kategori_id': '5dcba45c-b5de-437c-858b-50dbe7624f9b',
      'nama': 'Peralatan',
      'name': 'Peralatan',
    },
  ];

  final List<Map<String, dynamic>> _dummyFloors = [
    {
      'id': '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      'lantai_id': '45a8d4d0-ea99-404d-b35b-f39cd7315c2b',
      'nama': 'Gedung A - Kantor Pusat - Lantai 1',
      'name': 'Gedung A - Kantor Pusat - Lantai 1',
    },
    {
      'id': '7249c72a-642d-4ceb-afbe-61396587e37e',
      'lantai_id': '7249c72a-642d-4ceb-afbe-61396587e37e',
      'nama': 'Gedung A - Kantor Pusat - Lantai 2',
      'name': 'Gedung A - Kantor Pusat - Lantai 2',
    },
    {
      'id': 'a67fbf59-44e4-4537-a9b8-5c5193958116',
      'lantai_id': 'a67fbf59-44e4-4537-a9b8-5c5193958116',
      'nama': 'Gedung A - Kantor Pusat - Lantai 3',
      'name': 'Gedung A - Kantor Pusat - Lantai 3',
    },
    {
      'id': '5970908a-117c-4ab9-95f6-065ed4d8b04c',
      'lantai_id': '5970908a-117c-4ab9-95f6-065ed4d8b04c',
      'nama': 'Gedung B - Kantor Cabang - Lantai 1',
      'name': 'Gedung B - Kantor Cabang - Lantai 1',
    },
    {
      'id': 'a75e15c3-5990-4936-af85-2848d12d1901',
      'lantai_id': 'a75e15c3-5990-4936-af85-2848d12d1901',
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
    if (response.statusCode == null || response.statusCode == 0) return true;
    if (response.statusCode == 502 || response.statusCode == 503 || response.statusCode == 504) return true;
    try {
      final status = response.status;
      if (status.connectionError) return true;
    } catch (_) {}
    final bodyStr = (response.bodyString ?? response.body ?? '').toString();
    if (bodyStr.contains('ERR_NGROK_') || bodyStr.contains('ngrok') || bodyStr.contains('Tunnel not found')) {
      return true;
    }
    return false;
  }

  bool _hasTriggeredOfflineNotification = false;

  void _triggerOfflineNotificationTimer() {
    if (_hasTriggeredOfflineNotification) return;
    _hasTriggeredOfflineNotification = true;

    Timer(const Duration(seconds: 5), () {
      final newReport = {
        'id': '3',
        'laporan_id': '3',
        'title': 'AC Bocor',
        'location': 'Ruang Meeting 4',
        'description': 'AC Bocor di Ruang Meeting 4, air menetes deras.',
        'priority': 'URGENT',
        'status': 'pending',
        'kolaborasi': false,
        'category': 'AC & Udara',
        'created_at': DateTime.now().toIso8601String(),
        'photos': <String>[],
        'reporter': 'Asep'
      };
      if (!_dummyReports.any((r) => r['id'] == '3')) {
        _dummyReports.insert(0, newReport);
        debugPrint('Offline: Injected dummy report ID 3 for notification alert.');
      }
    });
  }

  bool get isLoggedIn => token.value != null && token.value!.isNotEmpty;
  bool get isOfflineMode => token.value == 'dummy_token';
  String? get lastRequestError => _lastRequestError;
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

      if (_isOfflineResponse(response)) {
        return _loginOffline(identifier, password);
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

      debugPrint('Login gagal: ${response.bodyString ?? response.body}');
      return false;
    } catch (e) {
      debugPrint('Error login: $e');
      return _loginOffline(identifier, password);
    }
  }

  Future<bool> _loginOffline(String identifier, String password) async {
    debugPrint('Server offline detected on login. Using dummy login...');
    final dummyRole = identifier.toLowerCase().contains('ob') ? 'OB' : 'KARYAWAN';
    final dummyUser = {
      'id': 'dummy_id',
      'username': identifier,
      'name': 'Rahman',
      'email': '$identifier@wgs.co.id',
      'role': dummyRole,
      'penugasan': dummyRole == 'OB' ? 'Gedung A - Lantai 1 & 2' : null,
    };
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
      final response = await _client.get(
        '/api/user/profile',
        headers: authHeaders(),
      );

      if (response.isOk) {
        return _responseBodyAsMap(response.body, response.bodyString);
      }

      if (_isOfflineResponse(response)) {
        return _getUserProfileOffline();
      }

      debugPrint(
        'Gagal ambil profile: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil profile: $e');
      return _getUserProfileOffline();
    }
  }

  Map<String, dynamic> _getUserProfileOffline() {
    final currentUser = user.value ?? {
      'id': 'dummy_id',
      'username': 'rahman',
      'name': 'Rahman',
      'email': 'rahman@wgs.co.id',
      'role': role.value ?? 'KARYAWAN',
      'penugasan': (role.value == 'OB') ? 'Gedung A - Lantai 1 & 2' : null,
    };
    return {
      'success': true,
      'data': {
        'user': currentUser,
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
    final updatedProfile =
        _profileFromResponse(body) ??
        <String, dynamic>{
          'nama': fullName,
          'profile_picture': localAvatarPath ?? avatarPath?.trim() ?? '',
        };

    await mergeUserData(updatedProfile);
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
  }) async {
    try {
      final response = await _client.get(
        '/api/checklist-harian',
        query: {'page': page.toString(), 'limit': limit.toString()},
        headers: authHeaders(),
      );

      if (response.isOk) {
        return _asMap(response.body);
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
    return {
      'success': true,
      'data': _dummyChecklist,
    };
  }

  Future<List<Map<String, dynamic>>> getReportCategories() async {
    final liveOptions = await _fetchOptionList(
      endpoints: const [
        '/api/karyawan/laporan/form',
        '/api/karyawan/laporan/form-data',
        '/api/karyawan/laporan/options',
        '/api/karyawan/laporan/create',
        '/api/karyawan/kategori-laporan',
        '/api/kategori-laporan',
        '/api/kategori',
      ],
      listKeys: const [
        'kategori',
        'kategori_laporan',
        'kategoriLaporan',
        'categories',
        'categoryOptions',
        'kategoriOptions',
        'items',
      ],
    );

    if (liveOptions.isNotEmpty) {
      return liveOptions;
    }
    return _dummyCategories;
  }

  Future<List<Map<String, dynamic>>> getReportFloors() async {
    final liveOptions = await _fetchOptionList(
      endpoints: const [
        '/api/karyawan/laporan/form',
        '/api/karyawan/laporan/form-data',
        '/api/karyawan/laporan/options',
        '/api/karyawan/laporan/create',
        '/api/karyawan/lantai',
        '/api/lantai',
        '/api/gedung/lantai',
      ],
      listKeys: const [
        'lantai',
        'lantai_gedung',
        'lantaiGedung',
        'floors',
        'floorOptions',
        'lantaiOptions',
        'items',
      ],
    );

    if (liveOptions.isNotEmpty) {
      return liveOptions;
    }
    return _dummyFloors;
  }

  Future<List<Map<String, dynamic>>> getReportRooms() async {
    final liveOptions = await _fetchOptionList(
      endpoints: const [
        '/api/karyawan/laporan/form',
        '/api/karyawan/laporan/form-data',
        '/api/karyawan/laporan/options',
        '/api/karyawan/laporan/create',
        '/api/karyawan/ruangan',
        '/api/ruangan',
        '/api/gedung/ruangan',
      ],
      listKeys: const [
        'ruangan',
        'ruangan_lantai',
        'ruanganLantai',
        'rooms',
        'roomOptions',
        'ruanganOptions',
        'lokasi',
        'locations',
        'locationOptions',
        'items',
      ],
    );

    if (liveOptions.isNotEmpty) {
      return liveOptions;
    }
    return _dummyRooms;
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

      if (_isOfflineResponse(response)) {
        return _getReportsOffline();
      }

      debugPrint(
        'Gagal ambil laporan karyawan: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil laporan karyawan: $e');
      return _getReportsOffline();
    }
  }

  Map<String, dynamic> _getReportsOffline() {
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

    try {
      final cleanPhotoPaths = photoPaths
          .map(_localUploadPath)
          .whereType<String>()
          .where((path) => path.isNotEmpty)
          .toList();

      final payload = <String, dynamic>{
        'lantai_id': floorId,
        'ruangan_id': roomId,
        'kategori_id': categoryId,
        'deskripsi_kendala': description.trim(),
        'prioritas': priority.trim().toUpperCase(),
      };

      if (cleanPhotoPaths.isNotEmpty) {
        final photos = cleanPhotoPaths
            .map(
              (photoPath) => MultipartFile(
                photoPath,
                filename: _filenameFromPath(photoPath),
                contentType: _contentTypeFromPath(photoPath),
              ),
            )
            .toList();
        payload['foto_masalah'] = photos;
      }

      final response = await _client.post(
        '/api/karyawan/laporan',
        FormData(payload),
        contentType: 'multipart/form-data',
        headers: authHeaders(),
      );

      if (_isOfflineResponse(response)) {
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
        return _asMap(response.body) ?? <String, dynamic>{'success': true};
      }

      _lastRequestError =
          _errorMessageFromResponse(response) ??
          'Laporan belum terkirim. Server menolak data laporan.';
      debugPrint(
        'Gagal kirim laporan: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error kirim laporan: $e');
      return _createEmployeeReportOffline(
        floorId: floorId,
        roomId: roomId,
        categoryId: categoryId,
        description: description,
        priority: priority,
        photoPaths: photoPaths,
      );
    }
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
      final response = await _client.patch(
        '/api/ob/laporan/$reportId',
        null,
        headers: authHeaders(),
      );

      if (_isOfflineResponse(response)) {
        return _takeObReportOffline(reportId);
      }

      if (response.isOk) {
        return _asMap(response.body) ?? <String, dynamic>{'success': true};
      }

      _lastRequestError =
          _takeReportErrorMessage(response) ??
          'Gagal mengambil laporan. Coba muat ulang daftar laporan.';
      debugPrint(
        'Gagal ambil laporan OB: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil laporan OB: $e');
      return _takeObReportOffline(reportId);
    }
  }

  Map<String, dynamic>? _takeObReportOffline(String reportId) {
    debugPrint('Offline: Simulating taking report...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index == -1) return null;

    final updated = Map<String, dynamic>.from(_dummyReports[index]);
    updated['status'] = 'proses';
    updated['ob_id'] = user.value?['id'] ?? 'dummy_ob_id';
    updated['ob_name'] = user.value?['name'] ?? 'Rahman';
    _dummyReports[index] = updated;

    return {
      'success': true,
      'data': updated,
    };
  }

  Future<Map<String, dynamic>?> getObReports({
    int page = 1,
    int limit = 10,
  }) async {
    _lastRequestError = null;

    const endpoints = [
      '/api/ob/laporan-masuk',
      '/api/ob/laporan/masuk',
      '/api/ob/dashboard/laporan',
      '/api/ob/dashboard/reports',
      '/api/ob/laporan',
      '/api/laporan-masuk',
      '/api/laporan/masuk',
      '/api/karyawan/laporan',
      '/api/laporan',
      '/api/reports',
    ];

    Response<dynamic>? lastResponse;
    Object? lastError;
    final mergedItems = <dynamic>[];
    Map<String, dynamic>? firstSuccessfulBody;

    for (final endpoint in endpoints) {
      try {
        final response = await _client.get(
          endpoint,
          query: {'page': page.toString(), 'limit': limit.toString()},
          headers: authHeaders(),
        );

        if (response.isOk) {
          final body =
              _responseBodyAsMap(response.body, response.bodyString) ??
              _asMap(response.body);
          firstSuccessfulBody ??= body;
          final items = _extractList(body ?? response.body, const [
            'laporan',
            'reports',
            'items',
            'data',
            'laporan_masuk',
            'laporanMasuk',
            'incoming_reports',
          ]);
          if (items != null) {
            mergedItems.addAll(items);
            continue;
          }
          if (response.body is List) {
            mergedItems.addAll(response.body as List);
            continue;
          }
          if (response.body != null) {
            firstSuccessfulBody ??= <String, dynamic>{'data': response.body};
          }
          continue;
        }

        lastResponse = response;
      } catch (e) {
        lastError = e;
      }
    }

    if (mergedItems.isNotEmpty) {
      return <String, dynamic>{'data': _dedupeReportItems(mergedItems)};
    }

    if (firstSuccessfulBody != null) {
      return firstSuccessfulBody;
    }

    final isOffline = lastResponse == null || _isOfflineResponse(lastResponse);
    if (isOffline) {
      _triggerOfflineNotificationTimer();
      return _getReportsOffline();
    }

    _lastRequestError =
        _errorMessageFromResponse(lastResponse) ??
                'Endpoint daftar laporan OB belum ditemukan di server.';
    debugPrint(
      'Gagal ambil laporan OB: ${lastResponse.bodyString ?? lastResponse.body}',
      );
    return null;
  }

  Future<Map<String, dynamic>?> submitObReportHistory({
    required String reportId,
    required String note,
    required List<String> photoPaths,
  }) async {
    _lastRequestError = null;

    try {
      final response = await _client.post(
        '/api/ob/laporan/$reportId/histori',
        FormData({
          'catatan': note,
          'foto_selesai': photoPaths
              .map(
                (path) => MultipartFile(
                  path,
                  filename: _filenameFromPath(path),
                  contentType: _contentTypeFromPath(path),
                ),
              )
              .toList(),
        }),
        contentType: 'multipart/form-data',
        headers: authHeaders(),
      );

      if (_isOfflineResponse(response)) {
        return _submitObReportHistoryOffline(reportId, note, photoPaths);
      }

      if (response.isOk) {
        return _asMap(response.body) ?? <String, dynamic>{'success': true};
      }

      _lastRequestError =
          _errorMessageFromResponse(response) ??
          'Gagal menyelesaikan laporan. Server menolak data histori.';
      debugPrint(
        'Gagal submit histori laporan OB: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error submit histori laporan OB: $e');
      return _submitObReportHistoryOffline(reportId, note, photoPaths);
    }
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
      final detail = _asMap(map?['laporan']) ?? _asMap(map?['report']) ?? map;
      final id =
          _firstText(map, const [
        'laporan_id',
        'report_id',
      ]) ??
          _firstText(detail, const [
        'id',
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
      final response = await _client.post(
        '/api/ob/laporan/$reportId/tolak',
        {'alasan_gagal': reason},
        headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
      );

      if (_isOfflineResponse(response)) {
        return _rejectObReportOffline(reportId, reason);
      }

      if (response.isOk) {
        return _asMap(response.body) ?? <String, dynamic>{'success': true};
      }

      _lastRequestError =
          _errorMessageFromResponse(response) ??
          'Gagal menolak laporan. Server menolak alasan yang dikirim.';
      debugPrint(
        'Gagal tolak laporan OB: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error tolak laporan OB: $e');
      return _rejectObReportOffline(reportId, reason);
    }
  }

  Map<String, dynamic>? _rejectObReportOffline(String reportId, String reason) {
    debugPrint('Offline: Simulating rejecting report...');
    final index = _dummyReports.indexWhere(
      (r) => r['id'] == reportId || r['laporan_id'] == reportId,
    );
    if (index == -1) return null;

    final updated = Map<String, dynamic>.from(_dummyReports[index]);
    updated['status'] = 'tolak';
    updated['reason'] = reason;
    _dummyReports[index] = updated;

    return {
      'success': true,
      'data': updated,
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
    await saveSession(
      tokenValue: token.value,
      userData: {...currentUser, ...updatedUserData},
    );
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
      {'nama': fullName},
      {'name': fullName},
      {'nama_lengkap': fullName},
    ];

    for (final payload in payloads) {
      final patchResponse = await _client.patch(
        '/api/user/profile',
        payload,
        contentType: 'application/json',
        headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
      );

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
        if (text.isNotEmpty) return text;
      }
    }

    final bodyString = response.bodyString?.trim();
    if (bodyString != null && bodyString.isNotEmpty && bodyString.length < 180) {
      return bodyString;
    }

    final statusCode = response.statusCode;
    if (statusCode == 401) {
      return 'Sesi login sudah tidak valid. Silakan login kembali.';
    }
    if (statusCode == 403) {
      return 'Akun Anda tidak memiliki akses untuk mengirim laporan.';
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
        final response = await _client.get(endpoint, headers: authHeaders());

        if (!response.isOk) continue;

        final body =
            _responseBodyAsMap(response.body, response.bodyString) ??
            _asMap(response.body);
        final rawItems = _extractList(body ?? response.body, listKeys);
        if (rawItems == null) continue;

        return rawItems.map(_asMap).whereType<Map<String, dynamic>>().toList();
      } catch (e) {
        debugPrint('Gagal ambil opsi laporan dari $endpoint: $e');
      }
    }

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
