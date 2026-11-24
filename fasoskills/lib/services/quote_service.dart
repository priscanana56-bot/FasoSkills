import '../config/api_config.dart';
import '../models/quote.dart';
import 'api_service.dart';

class QuoteService {
  final ApiService _api;

  QuoteService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Quote>> getQuotes() async {
    final data = await _api.get(ApiConfig.quotesUrl);
    return _api.parseList(data, Quote.fromJson);
  }

  Future<Quote> createQuote({
    required int requestId,
    required double amount,
    required int estimatedDays,
    String? message,
  }) async {
    final data = await _api.post(
      ApiConfig.quotesUrl,
      body: {
        'request_id': requestId,
        'amount': amount,
        'estimated_days': estimatedDays,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
    if (data is Map<String, dynamic>) {
      return Quote.fromJson(data);
    }
    throw Exception('Réponse invalide du serveur');
  }
}
