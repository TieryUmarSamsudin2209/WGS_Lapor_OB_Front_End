class EnvConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://stylar-nonseverable-denver.ngrok-free.dev',
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'wss://stylar-nonseverable-denver.ngrok-free.dev/ws',
  );

  static const bool useOfflineMode = bool.fromEnvironment(
    'USE_OFFLINE_MODE',
    defaultValue: false,
  );

  static const int connectionTimeout = int.fromEnvironment(
    'CONNECTION_TIMEOUT',
    defaultValue: 30000,
  );
}
