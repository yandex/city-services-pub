import '../base/route_node.dart';
import 'guard_context.dart';
import 'guard_result.dart';

/// {@template route_node_guard}
/// A guard that is invoked on every mutation of the navigation tree.
///
/// Implement [call] to inspect the proposed transition from [origin] to
/// [target] and return a [GuardResult] that either lets the mutation
/// continue, redirects it to a different tree, or cancels it.
/// {@endtemplate}
abstract interface class RouteNodeGuard {
  /// Invoked when the [RouteNode] state is about to change.
  ///
  /// [origin] is the current tree before the mutation. [target] is the
  /// proposed new tree. [context] is a shared scratch space that allows
  /// guards to share values with guards that run later in the same pipeline.
  ///
  /// Return one of:
  /// - [GuardResult.next] to allow the mutation to continue;
  /// - [GuardResult.redirect] to replace [target] with another tree;
  /// - [GuardResult.cancel] to discard the mutation.
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    GuardContext context,
  );
}
