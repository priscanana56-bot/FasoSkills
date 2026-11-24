class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  static String parseErrorBody(dynamic body) {
    if (body == null) return 'Erreur inconnue';
    if (body is String) return body;
    if (body is Map<String, dynamic>) {
      final parts = <String>[];
      for (final entry in body.entries) {
        final value = entry.value;
        if (value is List) {
          for (final item in value) {
            parts.add('${entry.key}: $item');
          }
        } else {
          parts.add('${entry.key}: $value');
        }
      }
      return parts.isEmpty ? 'Erreur inconnue' : parts.join('\n');
    }
    return body.toString();
  }

  static ApiException fromStatusCode(int statusCode, dynamic body) {
    final parsed = parseErrorBody(body);
    switch (statusCode) {
      case 400:
        return ApiException(
          parsed.isNotEmpty ? parsed : 'Requête invalide',
          statusCode: 400,
        );
      case 401:
        return ApiException(
          'Session expirée. Veuillez vous reconnecter.',
          statusCode: 401,
        );
      case 403:
        return ApiException('Accès refusé.', statusCode: 403);
      case 404:
        return ApiException('Ressource introuvable.', statusCode: 404);
      case 500:
        return ApiException(
          'Erreur serveur. Réessayez plus tard.',
          statusCode: 500,
        );
      default:
        return ApiException(
          parsed.isNotEmpty ? parsed : 'Erreur HTTP $statusCode',
          statusCode: statusCode,
        );
    }
  }
}
