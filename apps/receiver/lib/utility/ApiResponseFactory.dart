

class ApiResponseFactory {
  static bool returnResponse(statusCode) {
    switch (statusCode) {
      case 201:
      case 200:
        return true;
      case 400:
      case 404:
      case 401:
      case 403:
      case 500:
      default:
        return false;
    }
  }
}
