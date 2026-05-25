class ServerException implements Exception {}

class CacheException implements Exception {}

class AppDatabaseException implements Exception {
  final String message;
  AppDatabaseException(this.message);
}

abstract class Failure {}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class AppDatabaseFailure extends Failure {
  final String message;
  AppDatabaseFailure(this.message);
}
