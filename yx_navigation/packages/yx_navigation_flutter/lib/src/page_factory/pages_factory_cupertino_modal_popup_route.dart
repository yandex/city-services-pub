part of 'pages_factory.dart';

/// Page backing a [CupertinoModalPopupRoute] (as used by
/// `showCupertinoModalPopup`).
///
/// Wraps the route so it can participate in Navigator 2.0 while preserving
/// the original popup behaviour.
class CupertinoModalPopupRoutePage<T> extends Page<T> {
  final Route<T> route;
  final Completer<T?>? routeCompleter;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool semanticsDismissible;
  final Offset? anchorPoint;

  const CupertinoModalPopupRoutePage({
    required this.route,
    required this.barrierDismissible,
    required this.semanticsDismissible,
    this.routeCompleter,
    this.barrierColor,
    this.barrierLabel,
    this.anchorPoint,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    // For CupertinoModalPopupRoute, we return a NEW route with settings=this Page
    final originalRoute = route as ModalRoute<T>;

    return CupertinoModalPopupRoute<T>(
      builder: (context) => Builder(
        builder: (context) => originalRoute.buildPage(
          context,
          originalRoute.animation ?? kAlwaysDismissedAnimation,
          originalRoute.secondaryAnimation ?? kAlwaysDismissedAnimation,
        ),
      ),
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? '',
      semanticsDismissible: semanticsDismissible,
      // Passing `this` as settings makes the route page-based.
      settings: this,
      anchorPoint: anchorPoint,
    )..popped.then(
        (value) {
          if (routeCompleter?.isCompleted == false) {
            routeCompleter?.complete(value);
          }
        },
        onError: (e, s) {
          if (routeCompleter?.isCompleted == false) {
            routeCompleter?.completeError(e, s);
          }
        },
      );
  }
}

@immutable
class CupertinoModalPopupRoutePageFactory<T> extends PagesFactory<T> {
  final Route<T> route;
  final Completer<T?>? routeCompleter;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool semanticsDismissible;
  final Offset? anchorPoint;

  const CupertinoModalPopupRoutePageFactory({
    required this.route,
    required this.barrierDismissible,
    required this.semanticsDismissible,
    this.routeCompleter,
    this.barrierColor,
    this.barrierLabel,
    this.anchorPoint,
  }) : super._();

  @override
  Page<T> call(
    BuildContext context,
    RouteNode routeNode,
    LocalKey key,
    Widget child,
  ) =>
      CupertinoModalPopupRoutePage<T>(
        key: key,
        name: routeNode.route.id,
        arguments: routeNode.arguments,
        route: route,
        routeCompleter: routeCompleter,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        barrierLabel: barrierLabel,
        semanticsDismissible: semanticsDismissible,
        anchorPoint: anchorPoint,
      );
}
