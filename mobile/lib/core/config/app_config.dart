class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Sync intervals
  static const Duration syncInterval = Duration(hours: 24);

  // Pagination
  static const int pageSize = 20;

  // AI chat history limit
  static const int aiChatHistoryLimit = 50;

  // Murojaat rate limit (per day)
  static const int murojaatDailyLimit = 5;
}
