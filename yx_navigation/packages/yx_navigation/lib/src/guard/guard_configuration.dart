import 'package:meta/meta.dart';

import '../base/route_node.dart';
import 'default/redirect_route_node_guard.dart';
import 'guard_context.dart';
import 'guard_observer.dart';
import 'guard_result.dart';
import 'route_node_guard.dart';

/// {@template guard_configuration}
/// A composite [RouteNodeGuard] that runs a pipeline of guards in order.
///
/// [GuardConfiguration] wires together a list of [guards], an optional
/// [RedirectRouteNodeGuard] that runs first to guard against redirect loops,
/// and an optional [GuardObserver] that receives lifecycle events. The
/// pipeline stops as soon as a guard returns [GuardResultCancel], and
/// restarts against the new target when a guard returns
/// [GuardResultRedirect].
/// {@endtemplate}
class GuardConfiguration implements RouteNodeGuard {
  /// The raw list of guards passed to the constructor.
  final Iterable<RouteNodeGuard> _guards;

  /// {@macro redirect_route_node_guard}
  final RedirectRouteNodeGuard? _redirectGuard;

  /// Observer that receives guard pipeline events.
  ///
  /// {@macro guard_observer}
  final GuardObserver? observer;

  /// {@macro guard_configuration}
  const GuardConfiguration({
    Iterable<RouteNodeGuard> guards = const <RouteNodeGuard>[],
    RedirectRouteNodeGuard? redirectGuard,
    this.observer,
  })  : _guards = guards,
        _redirectGuard = redirectGuard;

  /// The effective list of guards to run, in order.
  ///
  /// Subclasses may override this to contribute additional guards
  /// dynamically.
  @mustCallSuper
  @protected
  Iterable<RouteNodeGuard> get guards => _guards;

  @nonVirtual
  @protected
  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    GuardContext context,
  ) =>
      onGuards(origin, target, context, null);

  @protected
  GuardResult onGuards(
    RouteNode origin,
    RouteNode target,
    GuardContext context,
    RouteNode? redirect,
  ) {
    final guards = List<RouteNodeGuard>.unmodifiable([
      if (_redirectGuard != null) _redirectGuard,
      ...this.guards,
    ]);
    return _processGuards(guards, target, origin, context, redirect);
  }

  GuardResult _processGuards(
    List<RouteNodeGuard> guards,
    RouteNode target,
    RouteNode origin,
    GuardContext context,
    RouteNode? redirect,
  ) {
    final newTarget = (redirect ?? target).toImmutable();
    observer?.onStart(origin, newTarget);

    for (final guard in guards) {
      try {
        observer?.onGuard(origin, newTarget, guard);
        final result = guard.call(origin, newTarget, context);

        switch (result) {
          case GuardResultNext():
            observer?.onNext(origin, newTarget, guard);
            continue;
          case GuardResultCancel():
            observer?.onCancel(origin, newTarget, guard);
            return result;
          case GuardResultRedirect(target: final redirect):
            observer?.onRedirect(origin, newTarget, redirect, guard);
            return _processGuards(guards, newTarget, origin, context, redirect);
        }
      } on Object catch (error, stackTrace) {
        observer?.onGuardError(origin, newTarget, error, stackTrace, guard);
        return GuardResult.cancel(reason: error);
      }
    }

    observer?.onNext(origin, newTarget, null);
    return redirect != null
        ? GuardResult.redirect(target: newTarget)
        : const GuardResult.next();
  }
}
