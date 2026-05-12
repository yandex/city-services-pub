import 'package:meta/meta.dart';

import '../../base/route_node.dart';
import '../guard_result.dart';
import '../route_node_guard.dart';

/// {@template redirect_route_node_guard}
/// A guard that detects and breaks infinite redirect loops.
///
/// [RedirectRouteNodeGuard] counts how many times guards have redirected
/// within a single mutation. When the counter reaches [maxRedirects] the
/// guard delegates to [onRedirect], which by default cancels the mutation.
/// {@endtemplate}
@immutable
class RedirectRouteNodeGuard implements RouteNodeGuard {
  /// Maximum number of redirects allowed within a single mutation.
  final int maxRedirects;

  /// Creates a [RedirectRouteNodeGuard] with the given [maxRedirects] limit.
  const RedirectRouteNodeGuard({this.maxRedirects = 5});

  /// Key used to store the redirect counter in the guard context.
  static const String key = '_redirect_count_key';

  @nonVirtual
  @override
  GuardResult call(
    RouteNode origin,
    RouteNode target,
    Map<String, Object> context,
  ) {
    final redirect = context[key];

    if (redirect != null && redirect is int) {
      if (redirect >= maxRedirects) {
        return onRedirect(origin, target, context, redirect);
      }

      context[key] = redirect + 1;
      return const GuardResult.next();
    }

    assert(redirect == null, 'Redirect must be null');
    context[key] = 0;
    return const GuardResult.next();
  }

  /// Invoked when the redirect counter reaches [maxRedirects].
  ///
  /// The default implementation returns [GuardResult.cancel]. Override in
  /// subclasses to customise the behaviour (for example, to redirect to an
  /// error route).
  @protected
  GuardResult onRedirect(
    RouteNode origin,
    RouteNode target,
    Map<String, Object> context,
    int redirectCount,
  ) =>
      const GuardResult.cancel(reason: 'Max redirects reached');
}
