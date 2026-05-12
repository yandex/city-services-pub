import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// {@template source_route_completer}
/// Helper class to complete a source [Route] by calling its protected
/// [Route.didComplete] method.
///
/// ## Problem
///
/// When integrating Navigator 1.0 routes into YxNavigation's declarative
/// architecture, we need to properly complete the original [Route] objects
/// when they are popped. This ensures that:
///
/// 1. The [Route.popped] Future completes correctly
/// 2. Lifecycle callbacks like [Route.didComplete] are invoked
/// 3. Result values are properly propagated
///
/// However, [Route.didComplete] is a **protected** method and can only be
/// called from within a [Route] subclass.
///
/// ## Why Not Use didPop?
///
/// The [Route.didPop] method might seem like the obvious choice, but it has
/// unreliable behavior across different [Route] subclasses:
///
/// ```dart
/// // Route (base class)
/// bool didPop(T? result) {
///   didComplete(result);  // always calls didComplete
///   return true;
/// }
///
/// // CupertinoPageRoute
/// bool didPop(T? result) {
///   if (hasLocalHistory) {
///     handleLocalHistory();
///     return false;  // didComplete NOT called!
///   }
///   return super.didPop(result);
/// }
///
/// // ModalRoute with PopScope
/// bool didPop(T? result) {
///   if (hasPendingPopScope) {
///     handlePopScope();
///     return false;  // didComplete NOT called!
///   }
///   return super.didPop(result);
/// }
/// ```
///
/// As shown above, various [Route] implementations override [didPop] with
/// custom logic that may return `false` without calling [didComplete],
/// leaving the route in an incomplete state.
///
/// ## Solution
///
/// [SourceRouteCompleter] solves this by:
///
/// 1. Extending [Route] to gain access to protected [didComplete]
/// 2. Storing a reference to the source [Route]
/// 3. Directly calling [didComplete] on the source route, bypassing
///    all complex [didPop] logic
///
/// This guarantees that the route is properly completed regardless of
/// its implementation details.
///
/// ## Usage
///
/// This class is used internally by [NavigatorCompatibilityOverrides]
/// and should not be used directly by application code.
///
/// ```dart
/// // Internal usage in NavigatorCompatibilityOverrides:
/// final sourceRouteCompleter = SourceRouteCompleter<T>(originalRoute);
///
/// // When pop completes, directly complete the source route:
/// routeCompleter.future.then(
///   sourceRouteCompleter.complete,
///   onError: (error, stackTrace) {
///     // Even on error, complete with null to prevent hanging
///     sourceRouteCompleter.complete(null);
///   },
/// );
/// ```
///
/// ## Implementation Details
///
/// The [complete] method directly invokes [Route.didComplete] on the
/// source route, ensuring:
///
/// * The [Route.popped] Future resolves with the provided result
/// * All route lifecycle hooks are properly invoked
/// * No intermediate logic can prevent completion
///
/// See also:
///
/// * [Route], the base class this helper works with
/// * [NavigatorCompatibilityOverrides], which uses this helper
/// * [Route.didComplete], the protected method being invoked
/// {@endtemplate}
@internal
class SourceRouteCompleter<T> extends Route<T> {
  /// The original [Route] whose [didComplete] will be called.
  final Route<T> _sourceRoute;

  /// {@macro source_route_completer}
  SourceRouteCompleter(this._sourceRoute);

  /// Completes the source route by calling its [didComplete] method.
  ///
  /// This directly invokes [Route.didComplete] on [_sourceRoute],
  /// bypassing any complex logic in [Route.didPop] implementations.
  ///
  /// The [result] is passed to [didComplete] and will be delivered
  /// to the caller who initiated the navigation.
  ///
  /// ## Parameters
  ///
  /// * [result] - The value to complete the route with. This is typically
  ///   the value passed to `Navigator.pop(result)`.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // When user pops the route:
  /// Navigator.of(context).pop('success');
  ///
  /// // Internally, NavigatorCompatibilityOverrides calls:
  /// sourceRouteCompleter.complete('success');
  ///
  /// // This ensures the original push Future resolves:
  /// final result = await Navigator.push(...); // 'success'
  /// ```
  void complete(T? result) => _sourceRoute.didComplete(result);
}
