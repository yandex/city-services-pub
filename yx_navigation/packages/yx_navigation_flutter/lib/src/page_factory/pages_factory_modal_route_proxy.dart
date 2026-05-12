part of 'pages_factory.dart';

class ModalRouteProxyPage<T> extends Page<T> {
  final Route<T> route;
  final Completer<T?>? routeCompleter;

  const ModalRouteProxyPage({
    required this.route,
    this.routeCompleter,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    var pageRoute = route;
    var fullscreenDialog = false;

    if (pageRoute is PageRoute<T>) {
      fullscreenDialog = pageRoute.fullscreenDialog;
    }

    // For ModalRoute types that don't have specialized Page implementations,
    // wrap in PageRouteBuilder to integrate with Navigator 2.0 Pages API.
    //
    // PopupRoute types (dialogs, menus) must not be wrapped in
    // PageRouteBuilder: wrapping breaks their internal overlay/animation
    // logic (null check errors in _setOpacities, etc.). PopupRoute types
    // must either:
    //   1. Have specialized adapters (DialogRoute, CupertinoDialogRoute, etc.)
    //   2. Work as pageless routes (PopupMenuRoute)
    //
    // Only wrap ModalRoute that is NOT a PopupRoute.
    if (pageRoute is ModalRoute<T> && pageRoute is! PopupRoute<T>) {
      pageRoute = PageRouteBuilder<T>(
        pageBuilder: pageRoute.buildPage,
        transitionsBuilder: pageRoute.buildTransitions,
        settings: this,
        maintainState: pageRoute.maintainState,
        allowSnapshotting: pageRoute.allowSnapshotting,
        transitionDuration: pageRoute.transitionDuration,
        opaque: pageRoute.opaque,
        barrierDismissible: pageRoute.barrierDismissible,
        barrierColor: pageRoute.barrierColor,
        barrierLabel: pageRoute.barrierLabel,
        reverseTransitionDuration: pageRoute.reverseTransitionDuration,
        fullscreenDialog: fullscreenDialog,
      );
    }

    pageRoute.popped.then(
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

    return pageRoute;
  }
}

@immutable
class ModalRouteProxyPageFactory<T> extends PagesFactory<T> {
  final Route<T> route;
  final Object? arguments;
  final String? name;
  final Completer<T?>? routeCompleter;

  const ModalRouteProxyPageFactory({
    required this.route,
    this.routeCompleter,
    this.arguments,
    this.name,
  }) : super._();

  @override
  Page<T> call(
    BuildContext context,
    RouteNode routeNode,
    LocalKey key,
    Widget child,
  ) =>
      ModalRouteProxyPage(
        name: name ?? routeNode.route.id,
        route: route,
        arguments: arguments ?? routeNode.arguments,
        key: key,
        routeCompleter: routeCompleter,
      );
}
