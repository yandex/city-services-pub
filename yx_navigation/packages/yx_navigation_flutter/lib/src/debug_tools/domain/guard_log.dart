part of 'log_types.dart';

/// Base class for guard logs.
sealed class GuardLog implements DebugLog {
  const GuardLog({required this.timestamp});

  @override
  final DateTime timestamp;
}

final class OnStartLog extends GuardLog {
  final RouteNode origin;
  final RouteNode target;

  const OnStartLog({
    required this.origin,
    required this.target,
    required super.timestamp,
  });
}

final class OnGuardLog extends GuardLog {
  final RouteNode origin;
  final RouteNode target;
  final RouteNodeGuard guard;

  const OnGuardLog({
    required this.origin,
    required this.target,
    required this.guard,
    required super.timestamp,
  });
}

final class OnNextLog extends GuardLog {
  final RouteNode origin;
  final RouteNode target;
  final RouteNodeGuard? guard;

  const OnNextLog({
    required this.origin,
    required this.target,
    required this.guard,
    required super.timestamp,
  });
}

final class OnCancelLog extends GuardLog {
  final RouteNode origin;
  final RouteNode target;
  final RouteNodeGuard guard;

  const OnCancelLog({
    required this.origin,
    required this.target,
    required this.guard,
    required super.timestamp,
  });
}

final class OnRedirectLog extends GuardLog {
  final RouteNode origin;
  final RouteNode target;
  final RouteNode redirect;
  final RouteNodeGuard? guard;

  const OnRedirectLog({
    required this.origin,
    required this.target,
    required this.redirect,
    required this.guard,
    required super.timestamp,
  });
}

final class OnGuardErrorLog extends GuardLog {
  final RouteNode origin;
  final RouteNode target;
  final Object error;
  final StackTrace stackTrace;
  final RouteNodeGuard guard;

  const OnGuardErrorLog({
    required this.origin,
    required this.target,
    required this.error,
    required this.stackTrace,
    required this.guard,
    required super.timestamp,
  });
}

final class OnGuardSyncLog extends GuardLog {
  final GuardSyncReason reason;

  const OnGuardSyncLog({
    required this.reason,
    required super.timestamp,
  });
}
