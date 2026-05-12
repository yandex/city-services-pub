import 'package:yx_navigation/yx_navigation.dart';

part 'deeplink_log.dart';
part 'guard_log.dart';
part 'state_manager_log.dart';

/// Base class for all debug logs.
sealed class DebugLog {
  DateTime get timestamp;
}
