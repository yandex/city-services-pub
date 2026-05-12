part of 'pages_factory.dart';

/// Page backing a low-level [RawDialogRoute].
///
/// Wraps the route so it can participate in Navigator 2.0 while preserving
/// the original transition configuration.
class RawDialogRoutePage<T> extends Page<T> {
  final Route<T> route;
  final Completer<T?>? routeCompleter;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final Offset? anchorPoint;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  const RawDialogRoutePage({
    required this.route,
    required this.barrierDismissible,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
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
    // For RawDialogRoute, we return a NEW RawDialogRoute with settings=this Page
    final originalRoute = route as ModalRoute<T>;

    return RawDialogRoute<T>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          originalRoute.buildPage(context, animation, secondaryAnimation),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      // Passing `this` as settings makes the route page-based.
      settings: this,
      anchorPoint: anchorPoint,
      transitionDuration: transitionDuration,
      transitionBuilder: (context, animation, secondaryAnimation, child) =>
          originalRoute.buildTransitions(
        context,
        animation,
        secondaryAnimation,
        child,
      ),
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
class RawDialogRoutePageFactory<T> extends PagesFactory<T> {
  final Route<T> route;
  final Completer<T?>? routeCompleter;
  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final Offset? anchorPoint;
  final Duration transitionDuration;
  final Duration reverseTransitionDuration;

  const RawDialogRoutePageFactory({
    required this.route,
    required this.barrierDismissible,
    required this.transitionDuration,
    required this.reverseTransitionDuration,
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
      RawDialogRoutePage<T>(
        key: key,
        name: routeNode.route.id,
        arguments: routeNode.arguments,
        route: route,
        routeCompleter: routeCompleter,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        barrierLabel: barrierLabel,
        anchorPoint: anchorPoint,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
      );
}
