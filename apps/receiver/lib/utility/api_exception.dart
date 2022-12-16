class ApiException implements Exception {
  final String _message;
  final String _prefix;

  ApiException(this._message, this._prefix);

  @override
  String toString() {
    return '$_prefix$_message';
  }
}

class FetchDataException extends ApiException {
  FetchDataException(String message)
      : super(message, 'Error During Communication: ');
}

class NotFoundException extends ApiException {
  NotFoundException(message) : super(message, 'Not Found: ');
}

class BadRequestException extends ApiException {
  BadRequestException(message) : super(message, 'Invalid Request: ');
}

class UnauthorisedException extends ApiException {
  UnauthorisedException(message) : super(message, 'Unauthorised: ');
}

class InvalidInputException extends ApiException {
  InvalidInputException(String message) : super(message, 'Invalid Input: ');
}
