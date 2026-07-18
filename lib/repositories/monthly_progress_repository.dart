import 'package:dio/dio.dart';
import '../models/monthly_progress.dart';
import '../core/network/dio_client.dart';
import '../core/cache/cache_manager.dart';
import '../core/network/exceptions.dart';

class MonthlyProgressRepository {
  final DioClient _dioClient;
  final CacheManager _cacheManager;
  static const String _allCacheKey = 'all_monthly_progress_cache';

  MonthlyProgressRepository(this._dioClient, this._cacheManager);

  Future<List<MonthlyProgress>> getMonthlyProgressForProject(String projectId) async {
    final cacheKey = 'monthly_progress_cache_$projectId';
    try {
      final response = await _dioClient.dio.get('/monthly_progress?project_id=eq.$projectId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        await _cacheManager.saveToCache(cacheKey, data);
        return data.map((json) => MonthlyProgress.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException("Failed to load monthly progress", response.statusCode);
      }
    } on DioException catch (e) {
      final cached = await _cacheManager.readFromCache(cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        return list.map((json) => MonthlyProgress.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw NetworkException(e.message ?? "Network error occurred");
    }
  }

  Future<List<MonthlyProgress>> getAllMonthlyProgress() async {
    try {
      final response = await _dioClient.dio.get('/monthly_progress');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        await _cacheManager.saveToCache(_allCacheKey, data);
        return data.map((json) => MonthlyProgress.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException("Failed to load all monthly progress", response.statusCode);
      }
    } on DioException catch (e) {
      final cached = await _cacheManager.readFromCache(_allCacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        return list.map((json) => MonthlyProgress.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw NetworkException(e.message ?? "Network error occurred");
    }
  }
}
