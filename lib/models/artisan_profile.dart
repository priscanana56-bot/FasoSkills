import '../config/api_config.dart';
import 'category.dart';
import 'user.dart';

class ArtisanProfile {
  final int id;
  final User user;
  final Category? category;
  final String? specialty;
  final String city;
  final int experienceYears;
  final String? bio;
  final String? availability;
  final double rating;
  final int completedJobs;
  final String profileStatus;

  ArtisanProfile({
    required this.id,
    required this.user,
    this.category,
    this.specialty,
    required this.city,
    required this.experienceYears,
    this.bio,
    this.availability,
    required this.rating,
    required this.completedJobs,
    required this.profileStatus,
  });

  String get displayName => user.fullName;
  String get profession => category?.name ?? specialty ?? 'Métier à compléter';
  String get avatarUrl => ApiConfig.resolveMediaUrl(user.profilePicture);
  bool get isComplete => profileStatus == 'complete';

  factory ArtisanProfile.fromJson(Map<String, dynamic> json) {
    return ArtisanProfile(
      id: json['id'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      specialty: json['specialty'] as String?,
      city: json['city'] as String? ?? '',
      experienceYears: json['experience_years'] as int? ?? 0,
      bio: json['bio'] as String?,
      availability: json['availability'] as String?,
      rating: _toDouble(json['rating']),
      completedJobs: json['completed_jobs'] as int? ?? 0,
      profileStatus: json['profile_status'] as String? ?? 'incomplete',
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
