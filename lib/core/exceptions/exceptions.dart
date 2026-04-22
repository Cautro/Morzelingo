abstract class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class InvalidData extends AppException {
  const InvalidData(super.message);
}

class TimeoutAppException extends AppException {
  const TimeoutAppException(super.message);
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class ParsingException extends AppException {
  const ParsingException(super.message);
}

class StorageException extends AppException {
  const StorageException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}