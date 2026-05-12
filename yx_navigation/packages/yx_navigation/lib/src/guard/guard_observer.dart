import 'package:meta/meta.dart';

import '../base/route_node.dart';
import 'guard_sync.dart';
import 'route_node_guard.dart';

/// {@template guard_observer}
/// Hooks into the lifecycle of the [RouteNodeGuard] pipeline.
///
/// Override the methods that are relevant to your use case (logging,
/// metrics, debugging). All default implementations are no-ops and must be
/// called via `super` when overridden.
/// {@endtemplate}
abstract class GuardObserver {
  /// {@macro guard_observer}
  const GuardObserver();

  /// Called before any guard runs for a mutation from [origin] to [target].
  @mustCallSuper
  void onStart(
    RouteNode origin,
    RouteNode target,
  ) {}

  /// Called immediately before [guard] is invoked.
  @mustCallSuper
  void onGuard(
    RouteNode origin,
    RouteNode target,
    RouteNodeGuard guard,
  ) {}

  /// Called when a guard returns [GuardResultNext].
  ///
  /// [guard] is `null` when emitted at the end of the pipeline, after every
  /// guard has passed.
  @mustCallSuper
  void onNext(
    RouteNode origin,
    RouteNode target,
    RouteNodeGuard? guard,
  ) {}

  /// Called when [guard] returns [GuardResultCancel].
  @mustCallSuper
  void onCancel(
    RouteNode origin,
    RouteNode target,
    RouteNodeGuard guard,
  ) {}

  /// Called when [guard] returns [GuardResultRedirect] with [redirect]
  /// as the new target.
  @mustCallSuper
  void onRedirect(
    RouteNode origin,
    RouteNode target,
    RouteNode redirect,
    RouteNodeGuard? guard,
  ) {}

  /// Called when [guard] throws [error] with [stackTrace].
  @mustCallSuper
  void onGuardError(
    RouteNode origin,
    RouteNode target,
    Object error,
    StackTrace stackTrace,
    RouteNodeGuard guard,
  ) {}

  /// Called when a [GuardSync] triggers re-evaluation with [reason].
  @mustCallSuper
  void onGuardSync(GuardSyncReason reason) {}
}
