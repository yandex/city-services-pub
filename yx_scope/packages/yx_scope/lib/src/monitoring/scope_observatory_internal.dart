import 'scope_observatory.dart';

class Logger {
  static void debug(Object message) =>
      ScopeObservatory.logger.log(LogType.debug, message);

  static void info(Object message) =>
      ScopeObservatory.logger.log(LogType.info, message);

  static void warning(Object message) =>
      ScopeObservatory.logger.log(LogType.warning, message);

  static void error(Object message, Object exception, StackTrace stackTrace) =>
      ScopeObservatory.logger.log(LogType.error, message,
          exception: exception, stackTrace: stackTrace);
}
