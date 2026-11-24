import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import 'api_exception.dart';

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', access);
    await prefs.setString('refreshToken', refresh);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  Future<void> saveTokens(String access, String refresh) async {
    await _saveTokens(access, refresh);
  }

  Future<bool> hasToken() async {
    final token = await _getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> _refreshAccessToken() async {
    final refresh = await _getRefreshToken();
    if (refresh == null) return false;

    final response = await _client.post(
      Uri.parse(ApiConfig.tokenRefreshUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _saveTokens(data['access'] as String, refresh);
      return true;
    }
    await clearTokens();
    return false;
  }

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getAccessToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    final body = _decodeBody(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException.fromStatusCode(response.statusCode, body);
  }

  Future<dynamic> _send(
    Future<http.Response> Function() request, {
    bool retry = true,
  }) async {
    try {
      final response = await request();
      if (response.statusCode == 401 && retry) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return await _send(request, retry: false);
        }
      }
      return await _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur réseau : $e');
    }
  }

  List<T> parseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (data is List) {
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    }
    if (data is Map<String, dynamic> && data['results'] is List) {
      return (data['results'] as List)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<dynamic> get(
    String url, {
    Map<String, String>? queryParams,
    bool auth = true,
  }) {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);
    return _send(
      () async => _client.get(uri, headers: await _headers(auth: auth)),
    );
  }

  Future<dynamic> post(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) {
    return _send(
      () async => _client.post(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> postMultipart(
    String url, {
    Map<String, String>? fields,
    List<({String fieldName, File file, String? contentType})> files = const [],
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(await _headers(auth: auth));
    if (fields != null) request.fields.addAll(fields);
    for (final fileEntry in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileEntry.fieldName,
          fileEntry.file.path,
          contentType: fileEntry.contentType != null
              ? MediaType.parse(fileEntry.contentType!)
              : null,
        ),
      );
    }
    return _send(() async {
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    });
  }

  Future<dynamic> patch(
    String url, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) {
    return _send(
      () async => _client.patch(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<dynamic> patchMultipart(
    String url, {
    Map<String, String>? fields,
    List<({String fieldName, File file, String? contentType})> files = const [],
    bool auth = true,
  }) async {
    final request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.headers.addAll(await _headers(auth: auth));
    if (fields != null) request.fields.addAll(fields);
    for (final fileEntry in files) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileEntry.fieldName,
          fileEntry.file.path,
          contentType: fileEntry.contentType != null
              ? MediaType.parse(fileEntry.contentType!)
              : null,
        ),
      );
    }
    return _send(() async {
      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    });
  }

  Future<dynamic> delete(String url, {bool auth = true}) {
    return _send(
      () async =>
          _client.delete(Uri.parse(url), headers: await _headers(auth: auth)),
    );
  }
}
