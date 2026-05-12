part of 'pages_factory.dart';

/// Page backing a [CupertinoDialogRoute] (as used by `showCupertinoDialog`).
///
/// Wraps the route so it can participate in Navigator 2.0 while preserving
/// the original dialog behaviour.
class CupertinoDialogRoutePage<T> extends Page<T> {
  final Route<T> route;
  final Completer<T?>? routeCompleter;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final Offset? anchorPoint;

  const CupertinoDialogRoutePage({
    required this.route,
    required this.barrierDismissible,
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
    // For CupertinoDialogRoute, we return a NEW CupertinoDialogRoute with settings=this Page
    final originalRoute = route as ModalRoute<T>;

    return CupertinoDialogRoute<T>(
      context: context,
      builder: (context) => Builder(
        builder: (context) => originalRoute.buildPage(
          context,
          originalRoute.animation ?? kAlwaysDismissedAnimation,
          originalRoute.secondaryAnimation ?? kAlwaysDismissedAnimation,
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
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
class CupertinoDialogRoutePageFactory<T> extends PagesFactory<T> {
  final Route<T> route;
  final Completer<T?>? routeCompleter;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final Offset? anchorPoint;

  const CupertinoDialogRoutePageFactory({
    required this.route,
    required this.barrierDismissible,
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
      CupertinoDialogRoutePage<T>(
        key: key,
        name: routeNode.route.id,
        arguments: routeNode.arguments,
        route: route,
        routeCompleter: routeCompleter,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        anchorPoint: anchorPoint,
      );
}
