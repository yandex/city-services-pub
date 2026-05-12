part of 'pages_factory.dart';

/// Page backing a Material [DialogRoute] (as used by `showDialog`).
///
/// Wraps the route so it can participate in Navigator 2.0 while preserving
/// the original dialog behaviour.
class DialogRoutePage<T> extends Page<T> {
  final Route<T> route;
  final Completer<T?>? routeCompleter;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final bool useSafeArea;
  final Offset? anchorPoint;

  const DialogRoutePage({
    required this.route,
    required this.barrierDismissible,
    required this.useSafeArea,
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
    // For DialogRoute, we return a NEW DialogRoute with settings=this Page
    // to make it page-based, while preserving all dialog-specific parameters
    final dialogRoute = DialogRoute<T>(
      context: context,
      builder: (context) {
        // Build the dialog content from original route
        final originalRoute = route as ModalRoute<T>;
        return Builder(
          builder: (context) => originalRoute.buildPage(
            context,
            originalRoute.animation ?? kAlwaysDismissedAnimation,
            originalRoute.secondaryAnimation ?? kAlwaysDismissedAnimation,
          ),
        );
      },
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      // Passing `this` as settings makes the route page-based.
      settings: this,
      anchorPoint: anchorPoint,
    );

    // Wire up completer
    dialogRoute.popped.then(
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

    return dialogRoute;
  }
}

@immutable
class DialogRoutePageFactory<T> extends PagesFactory<T> {
  final Route<T> route;
  final Completer<T?>? routeCompleter;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final bool useSafeArea;
  final Offset? anchorPoint;

  const DialogRoutePageFactory({
    required this.route,
    required this.barrierDismissible,
    required this.useSafeArea,
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
      DialogRoutePage<T>(
        key: key,
        name: routeNode.route.id,
        arguments: routeNode.arguments,
        route: route,
        routeCompleter: routeCompleter,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        useSafeArea: useSafeArea,
        anchorPoint: anchorPoint,
      );
}
