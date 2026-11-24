import 'user.dart';

class ServiceRequest {
  final int id;
  final String title;
  final String description;
  final String city;
  final String? address;
  final String status;
  final DateTime createdAt;
  final User? client;

  ServiceRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    this.address,
    required this.status,
    required this.createdAt,
    this.client,
  });

  String get fullAddress {
    if (address != null && address!.isNotEmpty) {
      return '$address, $city';
    }
    return city;
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      city: json['city'] as String? ?? '',
      address: json['address'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      client: json['client'] != null
          ? User.fromJson(json['client'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toCreateJson({
    required String title,
    required String description,
    required String city,
    String? address,
  }) {
    return {
      'title': title,
      'description': description,
      'city': city,
      if (address != null && address.isNotEmpty) 'address': address,
    };
  }
}
