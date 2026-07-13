class NotificationSocketClient {
  Stream<Map<String, dynamic>> get messages => const Stream.empty();

  Future<void> connect(Uri uri) async {}

  Future<void> disconnect() async {}

  void dispose() {}
}

NotificationSocketClient createNotificationSocketClient() {
  return NotificationSocketClient();
}
