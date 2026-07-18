import 'package:dio/dio.dart';
import '../models/authority.dart';
import '../core/network/dio_client.dart';
import '../core/cache/cache_manager.dart';
import '../core/network/exceptions.dart';

class AuthorityRepository {
  final DioClient _dioClient;
  final CacheManager _cacheManager;
  static const String _cacheKey = 'authorities_cache';

  AuthorityRepository(this._dioClient, this._cacheManager);

  Future<List<Authority>> getAllAuthorities() async {
    try {
      final response = await _dioClient.dio.get('/authorities');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        await _cacheManager.saveToCache(_cacheKey, data);
        return data.map((json) => Authority.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException("Failed to load authorities", response.statusCode);
      }
    } on DioException catch (e) {
      final cached = await _cacheManager.readFromCache(_cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        return list.map((json) => Authority.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw NetworkException(e.message ?? "Network error occurred");
    }
  }
}
