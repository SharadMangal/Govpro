import 'package:dio/dio.dart';
import 'supabase_config.dart';
import 'mock_interceptor.dart';

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio() {
    _configureClient();
  }

  void _configureClient() {
    // Timeout limits
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    final bool useRealSupabase = SupabaseConfig.anonKey.isNotEmpty;

    if (useRealSupabase) {
      // Connect to real Supabase REST API
      dio.options.baseUrl = SupabaseConfig.url;
      dio.options.headers = {
        'apikey': SupabaseConfig.anonKey,
        'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation', // Returns the row on insert/update/delete
      };
    } else {
      // Setup Mock mode
      dio.options.baseUrl = 'https://mock.supabase.co/rest/v1';
      dio.options.headers = {
        'Content-Type': 'application/json',
      };
      // Register our high-fidelity mock interceptor
      dio.interceptors.add(MockInterceptor());
    }

    // Add optional logger interceptor in debug mode
    dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      responseHeader: false,
      request: true,
      responseBody: false,
      error: true,
    ));
  }
}
