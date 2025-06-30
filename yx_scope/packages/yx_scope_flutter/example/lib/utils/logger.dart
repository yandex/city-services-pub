import 'package:yx_scope/yx_scope.dart';

class Logger extends ScopeLogger {
  const Logger();

  @override
  void log(
    LogType type,
    Object message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    if (type != LogType.error) {
      // ignore: avoid_print
      print('[INTERNAL] ${type.name}: $message');
    } else {
      // ignore: avoid_print
      print('[ERROR]: $message\n$exception\n$stackTrace');
    }
  }
}
