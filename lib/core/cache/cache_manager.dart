import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  static const String _syncTimePrefix = 'cache_sync_time_';

  // Get path to local file
  Future<File> _getCacheFile(String key) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$key.json');
  }

  // Save data to cache
  Future<void> saveToCache(String key, dynamic data) async {
    try {
      final file = await _getCacheFile(key);
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);

      // Save sync timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_syncTimePrefix$key', DateTime.now().toIso8601String());
    } catch (_) {
      // Fail silently for cache operations to not block network success
    }
  }

  // Read data from cache
  Future<dynamic> readFromCache(String key) async {
    try {
      final file = await _getCacheFile(key);
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return jsonDecode(jsonString);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // Get last synced time
  Future<DateTime?> getLastSyncedTime(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeStr = prefs.getString('$_syncTimePrefix$key');
      if (timeStr != null) {
        return DateTime.parse(timeStr);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // Clear cache
  Future<void> clearCache(String key) async {
    try {
      final file = await _getCacheFile(key);
      if (await file.exists()) {
        await file.delete();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_syncTimePrefix$key');
    } catch (_) {}
  }
}
