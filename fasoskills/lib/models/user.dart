import '../config/api_config.dart';

class User {
  final int id;
  final String fullName;
  final String? email;
  final String? phone;
  final String role;
  final String? profilePicture;
  final bool isVerified;
  final String? artisanProfileStatus;
  final int? artisanProfileId;

  User({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.profilePicture,
    this.isVerified = false,
    this.artisanProfileStatus,
    this.artisanProfileId,
  });

  String get avatarUrl => ApiConfig.resolveMediaUrl(profilePicture);
  bool get isArtisanProfileComplete => artisanProfileStatus == 'complete';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'] ?? false,
      artisanProfileStatus: json['artisan_profile_status'],
      artisanProfileId: json['artisan_profile_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_picture': profilePicture,
      'is_verified': isVerified,
    };
  }
}
