import 'dart:async';
import 'dart:convert';
import 'dart:io';

class NotificationSocketClient {
  final _messages = StreamController<Map<String, dynamic>>.broadcast();
  WebSocket? _socket;

  Stream<Map<String, dynamic>> get messages => _messages.stream;

  Future<void> connect(Uri uri) async {
    await disconnect();
    _socket = await WebSocket.connect(uri.toString());
    _socket?.listen(
      _handleMessage,
      onError: (_) {},
      onDone: () => _socket = null,
      cancelOnError: true,
    );
  }

  Future<void> disconnect() async {
    final socket = _socket;
    _socket = null;
    await socket?.close();
  }

  void dispose() {
    unawaited(_disconnectSafe());
    unawaited(_closeStreamSafe());
  }

  Future<void> _disconnectSafe() async {
    try {
      await disconnect();
    } catch (_) {}
  }

  Future<void> _closeStreamSafe() async {
    try {
      await _messages.close();
    } catch (_) {}
  }

  void _handleMessage(dynamic rawMessage) {
    final message = _decodeMessage(rawMessage);
    if (message != null && !_messages.isClosed) {
      _messages.add(message);
    }
  }

  Map<String, dynamic>? _decodeMessage(dynamic rawMessage) {
    final value = rawMessage is List<int>
        ? utf8.decode(rawMessage)
        : rawMessage?.toString();
    if (value == null || value.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(value);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}

    return null;
  }
}

NotificationSocketClient createNotificationSocketClient() {
  return NotificationSocketClient();
}
