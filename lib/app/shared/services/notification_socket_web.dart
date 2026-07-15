// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

class NotificationSocketClient {
  final _messages = StreamController<Map<String, dynamic>>.broadcast();
  html.WebSocket? _socket;

  Stream<Map<String, dynamic>> get messages => _messages.stream;

  Future<void> connect(Uri uri) async {
    await disconnect();

    final completer = Completer<void>();
    final socket = html.WebSocket(uri.toString());
    _socket = socket;

    socket.onOpen.first.then((_) {
      if (!completer.isCompleted) completer.complete();
    });
    socket.onError.first.then((_) {
      if (!completer.isCompleted) completer.complete();
    });
    socket.onMessage.listen((event) => _handleMessage(event.data));
    socket.onClose.listen((_) {
      if (_socket == socket) _socket = null;
    });

    return completer.future;
  }

  Future<void> disconnect() async {
    _socket?.close();
    _socket = null;
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
    final value = rawMessage?.toString();
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
