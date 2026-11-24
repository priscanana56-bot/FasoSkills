import 'artisan_profile.dart';
import 'service_request.dart';

class Quote {
  final int id;
  final ServiceRequest? request;
  final ArtisanProfile? artisan;
  final double amount;
  final int estimatedDays;
  final String? message;
  final String status;
  final DateTime createdAt;

  Quote({
    required this.id,
    this.request,
    this.artisan,
    required this.amount,
    required this.estimatedDays,
    this.message,
    required this.status,
    required this.createdAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as int,
      request: json['request'] != null
          ? ServiceRequest.fromJson(json['request'] as Map<String, dynamic>)
          : null,
      artisan: json['artisan'] != null
          ? ArtisanProfile.fromJson(json['artisan'] as Map<String, dynamic>)
          : null,
      amount: _toDouble(json['amount']),
      estimatedDays: json['estimated_days'] as int? ?? 0,
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toCreateJson({
    required int requestId,
    required double amount,
    required int estimatedDays,
    String? message,
  }) {
    return {
      'request': requestId,
      'amount': amount,
      'estimated_days': estimatedDays,
      if (message != null && message.isNotEmpty) 'message': message,
    };
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}
