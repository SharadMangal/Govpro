import 'package:dio/dio.dart';
import '../models/project.dart';
import '../core/network/dio_client.dart';
import '../core/cache/cache_manager.dart';
import '../core/network/exceptions.dart';

class ProjectRepository {
  final DioClient _dioClient;
  final CacheManager _cacheManager;
  static const String _cacheKey = 'projects_cache';

  ProjectRepository(this._dioClient, this._cacheManager);

  /// Fetches projects list. Returns cached data if network fails.
  Future<List<Project>> getAllProjects({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        // Try reading from cache first for instant load
        final cached = await _cacheManager.readFromCache(_cacheKey);
        if (cached != null) {
          final List<dynamic> list = cached as List<dynamic>;
          return list.map((json) => Project.fromJson(json as Map<String, dynamic>)).toList();
        }
      }

      // Fetch from API
      // Query select=*,authorities(*),contractors(*) to fetch joined tables
      final response = await _dioClient.dio.get('/projects?select=*,authorities(*),contractors(*)');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        
        // Save to cache
        await _cacheManager.saveToCache(_cacheKey, data);
        
        return data.map((json) => Project.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException("Failed to load projects", response.statusCode);
      }
    } on DioException catch (e) {
      // Network failure, attempt cache fallback
      final cached = await _cacheManager.readFromCache(_cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        return list.map((json) => Project.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw NetworkException(e.message ?? "Network error occurred");
    }
  }

  /// Fetches a single project by its ID
  Future<Project> getProjectById(String id) async {
    try {
      final response = await _dioClient.dio.get('/projects?id=eq.$id&select=*,authorities(*),contractors(*)');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        if (data.isNotEmpty) {
          return Project.fromJson(data.first as Map<String, dynamic>);
        } else {
          throw ServerException("Project not found", 404);
        }
      } else {
        throw ServerException("Server error fetching project", response.statusCode);
      }
    } on DioException catch (e) {
      // Try resolving from local cached list
      final cached = await _cacheManager.readFromCache(_cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        final match = list.firstWhere(
          (item) => item['id'] == id,
          orElse: () => null,
        );
        if (match != null) {
          return Project.fromJson(match as Map<String, dynamic>);
        }
      }
      throw NetworkException(e.message ?? "Network error occurred");
    }
  }
}
