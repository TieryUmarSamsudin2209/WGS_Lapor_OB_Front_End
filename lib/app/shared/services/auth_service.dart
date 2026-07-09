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
  String get normalizedRole => _normalizeRole(role.value ?? user.value?['role']);

  @override
  void onInit() {
    super.onInit();
    _client.baseUrl = baseUrl;
    _client.defaultContentType = 'application/json';
    configureClient(_client);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/api/auth/login',
        {
          'email': email,
          'password': password,
        },
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      final body = _asMap(response.body);
      final data = _asMap(body?['data']);
      final tokenValue = data?['token'] ?? data?['jwt_token'];
      final tokenText = tokenValue?.toString();
      final tokenClaims = _decodeJwtPayload(tokenText);
      final userData = _asMap(data?['user']) ??
          _userFromTokenClaims(
            tokenClaims,
            fallbackEmail: email,
          );

      if (response.isOk && body?['success'] == true && tokenText != null) {
        await saveSession(
          tokenValue: tokenText,
          userData: userData,
        );
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
        return _asMap(response.body);
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
    required String fallbackEmail,
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

    userData.putIfAbsent('email', () => fallbackEmail);
    userData.putIfAbsent('role', () => _roleFromEmail(fallbackEmail));
    return userData.isEmpty ? null : userData;
  }

  String? _roleFromEmail(String email) {
    final username = email.split('@').first.toLowerCase();
    if (username.startsWith('ob')) return 'OB';
    if (username.startsWith('admin')) return 'ADMIN';
    if (username.startsWith('hr')) return 'HR';
    if (username.startsWith('karyawan')) return 'KARYAWAN';
    return null;
  }
}
