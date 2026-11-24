import '../config/api_config.dart';
import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _api;

  CategoryService({ApiService? api}) : _api = api ?? ApiService();

  Future<List<Category>> getCategories() async {
    final data = await _api.get(ApiConfig.categoriesUrl, auth: false);
    return _api.parseList(data, Category.fromJson);
  }
}
