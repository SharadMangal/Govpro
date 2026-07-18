import 'package:dio/dio.dart';
import '../models/notification_item.dart';
import '../core/network/dio_client.dart';
import '../core/cache/cache_manager.dart';
import '../core/network/exceptions.dart';

class NotificationRepository {
  final DioClient _dioClient;
  final CacheManager _cacheManager;
  static const String _cacheKey = 'notifications_cache';

  NotificationRepository(this._dioClient, this._cacheManager);

  Future<List<NotificationItem>> getAllNotifications() async {
    try {
      final response = await _dioClient.dio.get('/notifications');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        await _cacheManager.saveToCache(_cacheKey, data);
        return data.map((json) => NotificationItem.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException("Failed to load notifications", response.statusCode);
      }
    } on DioException catch (e) {
      final cached = await _cacheManager.readFromCache(_cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        return list.map((json) => NotificationItem.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw NetworkException(e.message ?? "Network error occurred");
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await _dioClient.dio.patch(
        '/notifications?id=eq.$id',
        data: {'is_read': true},
      );
      
      if (response.statusCode == 200) {
        // Refresh local cache by re-fetching
        await getAllNotifications();
      } else {
        throw ServerException("Failed to update notification read status", response.statusCode);
      }
    } on DioException catch (e) {
      // Local fallback edit to cache if network is down
      final cached = await _cacheManager.readFromCache(_cacheKey);
      if (cached != null) {
        final List<dynamic> list = cached as List<dynamic>;
        final index = list.indexWhere((n) => n['id'] == id);
        if (index != -1) {
          list[index]['is_read'] = true;
          await _cacheManager.saveToCache(_cacheKey, list);
        }
      } else {
        throw NetworkException(e.message ?? "Network error occurred");
      }
    }
  }
}
