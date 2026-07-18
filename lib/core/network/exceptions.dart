class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = "No Internet connection or timeout."]);

  @override
  String toString() => "NetworkException: $message";
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => "ServerException ($statusCode): $message";
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);

  @override
  String toString() => "CacheException: $message";
}
