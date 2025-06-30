/// Class for diagnostic purposes.
///
/// Logging, state of scopes, info about dependencies.
class ScopeObservatory {
  // Set this logger in order to log event in scopes.
  // By default it logs nothing.
  static ScopeLogger logger = const ScopeLogger();

  const ScopeObservatory._();
}

class ScopeLogger {
  const ScopeLogger();

  void log(
    LogType type,
    Object message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    // Override in order to log event in scopes
  }
}

enum LogType {
  debug,
  info,
  warning,
  error,
}
