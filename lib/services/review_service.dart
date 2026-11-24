import '../config/api_config.dart';
import '../models/review.dart';
import 'api_service.dart';

class ReviewService {
  final ApiService _api;

  ReviewService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Review>> getReviews() async {
    final data = await _api.get(ApiConfig.reviewsUrl, auth: false);
    return _api.parseList(data, Review.fromJson);
  }

  Future<List<Review>> getReviewsForArtisan(int artisanId) async {
    final all = await getReviews();
    return List<Review>.from(all.where((r) => r.artisan.id == artisanId));
  }

  Future<Review> createReview({
    required int artisanId,
    required int rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{'artisan': artisanId, 'rating': rating};
    if (comment != null && comment.isNotEmpty) {
      body['comment'] = comment;
    }

    final data =
        await _api.post(ApiConfig.reviewsUrl, body: body)
            as Map<String, dynamic>;
    return Review.fromJson(data);
  }
}
