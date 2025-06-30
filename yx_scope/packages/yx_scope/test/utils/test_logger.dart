import 'package:yx_scope/src/monitoring/scope_observatory.dart';

class TestLogger extends ScopeLogger {
  const TestLogger();

  @override
  void log(
    LogType type,
    Object message, {
    Object? exception,
    StackTrace? stackTrace,
  }) {
    if (type != LogType.error) {
      // ignore: avoid_print
      print('${type.name}: $message');
    } else {
      // ignore: avoid_print
      print('ERROR: $message\n$exception\n$stackTrace');
    }
  }
}
