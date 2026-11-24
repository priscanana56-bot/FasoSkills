import 'artisan_profile.dart';
import 'user.dart';

class Review {
  final int id;
  final User client;
  final ArtisanProfile artisan;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.client,
    required this.artisan,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      client: User.fromJson(json['client'] as Map<String, dynamic>),
      artisan: ArtisanProfile.fromJson(json['artisan'] as Map<String, dynamic>),
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toCreateJson({
    required int artisanId,
    required int rating,
    String? comment,
  }) {
    return {
      'artisan': artisanId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
  }
}
