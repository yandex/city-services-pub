part of 'log_types.dart';

/// Base class for state manager logs.
sealed class StateManagerLog implements DebugLog {
  const StateManagerLog({required this.timestamp});

  @override
  final DateTime timestamp;
}

final class OnCreatedLog extends StateManagerLog {
  const OnCreatedLog({required super.timestamp});
}

final class MutationLog extends StateManagerLog {
  final Mutation mutation;

  const MutationLog({
    required this.mutation,
    required super.timestamp,
  });
}

final class ErrorLog extends StateManagerLog {
  final Object error;
  final StackTrace stackTrace;

  const ErrorLog({
    required this.error,
    required this.stackTrace,
    required super.timestamp,
  });
}

final class OnCloseLog extends StateManagerLog {
  const OnCloseLog({required super.timestamp});
}
