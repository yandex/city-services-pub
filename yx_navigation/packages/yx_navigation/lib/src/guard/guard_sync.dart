import 'dart:async';

import 'package:meta/meta.dart';

import 'guard_observer.dart';

/// {@template guard_sync}
/// A broadcast sink used to re-trigger the guard pipeline on demand.
///
/// Push a [GuardSyncReason] into [GuardSync] when an external condition has
/// changed and the current navigation state must be re-evaluated by the
/// guards (for example, after authentication state changes and a redirect
/// guard should reconsider the current tree).
/// {@endtemplate}
@immutable
class GuardSync implements Sink<GuardSyncReason> {
  final _controller = StreamController<GuardSyncReason>.broadcast();

  /// {@macro guard_observer}
  final GuardObserver? _observer;

  /// Stream of re-evaluation reasons pushed into this sync.
  Stream<GuardSyncReason> get stream => _controller.stream;

  /// {@macro guard_sync}
  GuardSync({GuardObserver? observer}) : _observer = observer;

  /// Pushes [reason] into the sync. Equivalent to [add].
  @nonVirtual
  void sync(GuardSyncReason reason) => add(reason);

  /// Pushes [data] into the sync, notifying the observer and listeners.
  @nonVirtual
  @override
  void add(GuardSyncReason data) {
    _observer?.onGuardSync(data);
    _controller.add(data);
  }

  /// Closes the underlying stream controller.
  @mustCallSuper
  @override
  Future<void> close() => _controller.close();
}

/// {@template guard_sync_reason}
/// Describes why guards should re-evaluate the current navigation state.
/// {@endtemplate}
@immutable
class GuardSyncReason {
  /// A human-readable message describing the reason.
  final String message;

  /// {@macro guard_sync_reason}
  const GuardSyncReason({required this.message});

  @override
  String toString() => 'ReevaluateReason: $message';

  @override
  bool operator ==(Object other) =>
      other is GuardSyncReason && other.message == message;

  @override
  int get hashCode => message.hashCode;
}
