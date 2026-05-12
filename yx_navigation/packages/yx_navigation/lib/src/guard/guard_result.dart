import '../base/route_node.dart';

/// {@template guard_result}
/// The outcome of a [RouteNodeGuard] invocation.
///
/// A guard returns one of three values:
/// - [GuardResultNext] to let the mutation continue unchanged;
/// - [GuardResultRedirect] to replace the proposed target with a different
///   tree;
/// - [GuardResultCancel] to discard the mutation entirely.
/// {@endtemplate}
sealed class GuardResult {
  /// {@macro guard_result}
  const GuardResult();

  /// {@macro guard_result_next}
  const factory GuardResult.next() = GuardResultNext;

  /// {@macro guard_result_cancel}
  const factory GuardResult.cancel({
    Object? reason,
  }) = GuardResultCancel;

  /// {@macro guard_result_redirect}
  const factory GuardResult.redirect({
    required RouteNode target,
  }) = GuardResultRedirect;
}

/// {@template guard_result_next}
/// Signals that the mutation should continue to the next guard.
/// {@endtemplate}
final class GuardResultNext implements GuardResult {
  /// {@macro guard_result_next}
  const GuardResultNext();
}

/// {@template guard_result_cancel}
/// Signals that the mutation should be cancelled.
/// {@endtemplate}
final class GuardResultCancel implements GuardResult {
  /// Optional reason describing why the mutation was cancelled.
  final Object? reason;

  /// {@macro guard_result_cancel}
  const GuardResultCancel({this.reason});
}

/// {@template guard_result_redirect}
/// Signals that the mutation should be redirected to a different [target].
/// {@endtemplate}
final class GuardResultRedirect implements GuardResult {
  /// The new [RouteNode] to navigate to instead of the proposed target.
  final RouteNode target;

  /// {@macro guard_result_redirect}
  const GuardResultRedirect({required this.target});
}
