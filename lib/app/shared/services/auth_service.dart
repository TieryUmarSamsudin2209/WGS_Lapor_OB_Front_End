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

  bool get isLoggedIn => token.value != null && token.value!.isNotEmpty;
  String get normalizedRole =>
      _normalizeRole(role.value ?? user.value?['role']);

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
      return false;
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

      debugPrint(
        'Gagal ambil profile: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil profile: $e');
      return null;
    }
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
          'profile_picture': ?localAvatarPath,
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

      debugPrint(
        'Gagal ambil detail laporan: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil detail laporan: $e');
      return null;
    }
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

      debugPrint(
        'Gagal ambil checklist harian: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil checklist harian: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getReportCategories() {
    return _fetchOptionList(
      endpoints: const [
        '/api/karyawan/kategori-laporan',
        '/api/kategori-laporan',
        '/api/kategori',
      ],
      listKeys: const ['kategori', 'kategori_laporan', 'categories', 'items'],
    );
  }

  Future<List<Map<String, dynamic>>> getReportFloors() {
    return _fetchOptionList(
      endpoints: const [
        '/api/karyawan/lantai',
        '/api/lantai',
        '/api/gedung/lantai',
      ],
      listKeys: const ['lantai', 'floors', 'items'],
    );
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

      debugPrint(
        'Gagal ambil laporan karyawan: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil laporan karyawan: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createEmployeeReport({
    required String floorId,
    required String categoryId,
    required String description,
    required String priority,
    required List<String> photoPaths,
  }) async {
    try {
      final cleanPhotoPaths = photoPaths
          .map(_localUploadPath)
          .whereType<String>()
          .where((path) => path.isNotEmpty)
          .toList();

      final payload = <String, dynamic>{
        'lantai_id': floorId,
        'kategori_id': categoryId,
        'deskripsi_kendala': description.trim(),
        'prioritas': priority.trim().toUpperCase(),
      };

      if (cleanPhotoPaths.isNotEmpty) {
        final photoPath = cleanPhotoPaths.first;
        payload['foto_masalah'] = MultipartFile(
          photoPath,
          filename: _filenameFromPath(photoPath),
          contentType: _contentTypeFromPath(photoPath),
        );
      }

      final response = await _client.post(
        '/api/karyawan/laporan',
        FormData(payload),
        contentType: 'multipart/form-data',
        headers: authHeaders(),
      );

      if (response.isOk || response.statusCode == 201) {
        return _asMap(response.body) ?? <String, dynamic>{'success': true};
      }

      debugPrint(
        'Gagal kirim laporan: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error kirim laporan: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> takeObReport(String reportId) async {
    try {
      final response = await _client.patch(
        '/api/ob/laporan/$reportId',
        null,
        headers: authHeaders(),
      );

      if (response.isOk) {
        return _asMap(response.body) ?? <String, dynamic>{'success': true};
      }

      debugPrint(
        'Gagal ambil laporan OB: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil laporan OB: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getObReports({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _client.get(
        '/api/ob/laporan',
        query: {'page': page.toString(), 'limit': limit.toString()},
        headers: authHeaders(),
      );

      if (response.isOk) {
        return _asMap(response.body);
      }

      debugPrint(
        'Gagal ambil laporan OB: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error ambil laporan OB: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> submitObReportHistory({
    required String reportId,
    required String note,
    required List<String> photoPaths,
  }) async {
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

      if (response.isOk) {
        return _asMap(response.body) ?? <String, dynamic>{'success': true};
      }

      debugPrint(
        'Gagal submit histori laporan OB: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error submit histori laporan OB: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> rejectObReport({
    required String reportId,
    required String reason,
  }) async {
    try {
      final response = await _client.post(
        '/api/ob/laporan/$reportId/tolak',
        {'alasan_gagal': reason},
        headers: authHeaders(extra: const {'Content-Type': 'application/json'}),
      );

      if (response.isOk) {
        return _asMap(response.body) ?? <String, dynamic>{'success': true};
      }

      debugPrint(
        'Gagal tolak laporan OB: ${response.bodyString ?? response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error tolak laporan OB: $e');
      return null;
    }
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
