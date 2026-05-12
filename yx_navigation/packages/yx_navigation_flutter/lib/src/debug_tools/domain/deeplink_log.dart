part of 'log_types.dart';

/// Base class for deeplink logs.
sealed class DeeplinkLog implements DebugLog {
  const DeeplinkLog({required this.timestamp});

  @override
  final DateTime timestamp;
}

final class DeeplinkReceivedLog extends DeeplinkLog {
  final Uri uri;
  final RouteNode currentState;

  const DeeplinkReceivedLog({
    required this.uri,
    required this.currentState,
    required super.timestamp,
  });
}

final class DeeplinkNavigateLog extends DeeplinkLog {
  final Uri uri;
  final RouteNode currentState;
  final RouteNode targetState;

  const DeeplinkNavigateLog({
    required this.uri,
    required this.currentState,
    required this.targetState,
    required super.timestamp,
  });
}

final class DeeplinkHandledLog extends DeeplinkLog {
  final Uri uri;
  final RouteNode currentState;

  const DeeplinkHandledLog({
    required this.uri,
    required this.currentState,
    required super.timestamp,
  });
}

final class DeeplinkSkippedLog extends DeeplinkLog {
  final Uri uri;
  final RouteNode currentState;

  const DeeplinkSkippedLog({
    required this.uri,
    required this.currentState,
    required super.timestamp,
  });
}

final class DeeplinkErrorLog extends DeeplinkLog {
  final Uri uri;
  final RouteNode currentState;
  final Object error;
  final StackTrace stackTrace;

  const DeeplinkErrorLog({
    required this.uri,
    required this.currentState,
    required this.error,
    required this.stackTrace,
    required super.timestamp,
  });
}
