import '../config/api_config.dart';
import '../models/service_request.dart';
import 'api_service.dart';

class RequestService {
  final ApiService _api;

  RequestService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<ServiceRequest>> getRequests() async {
    final data = await _api.get(ApiConfig.requestsUrl);
    return _api.parseList(data, ServiceRequest.fromJson);
  }

  Future<ServiceRequest> getRequestById(int id) async {
    final data =
        await _api.get(ApiConfig.requestDetailUrl(id)) as Map<String, dynamic>;
    return ServiceRequest.fromJson(data);
  }

  Future<ServiceRequest> createRequest({
    required String title,
    required String description,
    required String city,
    String? address,
  }) async {
    final data =
        await _api.post(
              ApiConfig.requestsUrl,
              body:
                  ServiceRequest(
                    id: 0,
                    title: title,
                    description: description,
                    city: city,
                    address: address,
                    status: 'pending',
                    createdAt: DateTime.now(),
                  ).toCreateJson(
                    title: title,
                    description: description,
                    city: city,
                    address: address,
                  ),
            )
            as Map<String, dynamic>;
    return ServiceRequest.fromJson(data);
  }

  Future<ServiceRequest> updateRequestStatus({
    required int requestId,
    required String status,
  }) async {
    final data = await _api.patch(
      ApiConfig.requestDetailUrl(requestId),
      body: {'status': status},
    );
    if (data is Map<String, dynamic>) {
      return ServiceRequest.fromJson(data);
    }
    throw Exception('Réponse invalide du serveur');
  }
}
