import '../config/api_config.dart';
import '../models/artisan_profile.dart';
import 'api_service.dart';
import 'dart:io';

class ArtisanService {
  final ApiService _api;

  ArtisanService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<ArtisanProfile>> getArtisans({
    int? categoryId,
    String? city,
    String? search,
    String? ordering,
  }) async {
    final params = <String, String>{};
    if (categoryId != null) params['category'] = categoryId.toString();
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (ordering != null && ordering.isNotEmpty) params['ordering'] = ordering;

    final data = await _api.get(
      ApiConfig.artisansUrl,
      queryParams: params,
      auth: false,
    );
    return _api.parseList(data, ArtisanProfile.fromJson);
  }

  Future<ArtisanProfile> getArtisanById(int id) async {
    final data =
        await _api.get(ApiConfig.artisanDetailUrl(id), auth: false)
            as Map<String, dynamic>;
    return ArtisanProfile.fromJson(data);
  }

  Future<ArtisanProfile> getCurrentArtisanProfile() async {
    final data =
        await _api.get('${ApiConfig.artisansUrl}me/') as Map<String, dynamic>;
    return ArtisanProfile.fromJson(data);
  }

  Future<ArtisanProfile> updateCurrentArtisanProfile({
    int? categoryId,
    String? specialty,
    String? city,
    int? experienceYears,
    String? bio,
    String? availability,
    File? profilePicture,
    String? profileStatus,
  }) async {
    final fields = <String, String>{};
    if (categoryId != null) fields['category_id'] = categoryId.toString();
    if (specialty != null) fields['specialty'] = specialty;
    if (city != null) fields['city'] = city;
    if (experienceYears != null) {
      fields['experience_years'] = experienceYears.toString();
    }
    if (bio != null) fields['bio'] = bio;
    if (availability != null) fields['availability'] = availability;
    if (profileStatus != null) fields['profile_status'] = profileStatus;

    if (fields.isEmpty && profilePicture == null) {
      throw Exception('Aucune donnée à enregistrer');
    }

    if (profilePicture != null) {
      final data = await _api.patchMultipart(
        '${ApiConfig.artisansUrl}me/',
        fields: fields,
        files: [
          (
            fieldName: 'profile_picture',
            file: profilePicture,
            contentType: 'image/jpeg',
          ),
        ],
      );
      if (data is Map<String, dynamic>) {
        return ArtisanProfile.fromJson(data);
      }
      throw Exception('Réponse invalide du serveur');
    }

    final data = await _api.patch('${ApiConfig.artisansUrl}me/', body: fields);
    if (data is Map<String, dynamic>) {
      return ArtisanProfile.fromJson(data);
    }
    throw Exception('Réponse invalide du serveur');
  }
}
