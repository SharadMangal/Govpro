import 'package:dio/dio.dart';
import '../models/material_item.dart';
import '../core/network/dio_client.dart';
import '../core/cache/cache_manager.dart';
import '../core/network/exceptions.dart';

class MaterialRepository {
  final DioClient _dioClient;
  final CacheManager _cacheManager;

  MaterialRepository(this._dioClient, this._cacheManager);

  Future<List<MaterialItem>> getMaterialsForProject(String projectId) async {
    final cacheKey = 'materials_cache_$projectId';
    try {
      final response = await _dioClient.dio.get('/materials?project_id=eq.$projectId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        await _cacheManager.saveToCache(cacheKey, data);
        return data.map((json) => MaterialItem.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException("Failed to load materials", response.statusCode);
      }
    } on DioException catch (e) {
      final cached = await _cacheManager.readFromCache(cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        return list.map((json) => MaterialItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw NetworkException(e.message ?? "Network error occurred");
    }
  }
}
