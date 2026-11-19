/// Error raised by the REST layer. Carries the HTTP status, the message returned
/// by the backend and any per-field validation errors.
class ApiException implements Exception {
  const ApiException(
    this.statusCode,
    this.message, {
    this.fieldErrors = const {},
  });

  final int statusCode;
  final String message;
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => statusCode == 401;
  bool get isConflict => statusCode == 409;
  bool get isValidationError => statusCode == 400;

  @override
  String toString() => message;
}
