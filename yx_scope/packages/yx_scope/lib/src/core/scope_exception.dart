// This exception must be throw in cases when
// a consumer of this package uses it
// in some inappropriate way.
class ScopeException implements Exception {
  final String message;

  const ScopeException(this.message);

  @override
  String toString() => 'ScopeException: $message';
}

// This error must be throw in cases when
// the problem happens because of
// internal code problems of this package.
class ScopeError extends ScopeException {
  const ScopeError(String message) : super(message);

  @override
  String toString() => 'ScopeError: $message';
}
