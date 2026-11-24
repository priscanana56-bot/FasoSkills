class ApiConfig {
  /// Base API — utiliser 10.0.2.2 sur émulateur Android.
  static const String host = 'http://127.0.0.1:8000';
  static const String baseUrl = '$host/api';

  static const String loginUrl = '$baseUrl/login/';
  static const String registerUrl = '$baseUrl/register/';
  static const String tokenRefreshUrl = '$baseUrl/auth/refresh/';

  static const String usersUrl = '$baseUrl/users/';
  static const String meUrl = '$baseUrl/users/me/';
  static const String artisansUrl = '$baseUrl/artisans/';
  static const String categoriesUrl = '$baseUrl/categories/';
  static const String requestsUrl = '$baseUrl/requests/';
  static const String quotesUrl = '$baseUrl/quotes/';
  static const String reviewsUrl = '$baseUrl/reviews/';
  static const String conversationsUrl = '$baseUrl/conversations/';

  static String artisanDetailUrl(int id) => '$artisansUrl$id/';
  static String requestDetailUrl(int id) => '$requestsUrl$id/';
  static String quoteDetailUrl(int id) => '$quotesUrl$id/';
  static String conversationMessagesUrl(int id) =>
      '$conversationsUrl$id/messages/';
  static String conversationSendUrl(int id) => '$conversationsUrl$id/send/';

  static String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$host${path.startsWith('/') ? path : '/$path'}';
  }
}
