part of 'pages_factory.dart';

@immutable
class CupertinoPageFactory<T> extends PagesFactory<T> {
  /// {@macro flutter.cupertino.CupertinoRouteTransitionMixin.title}
  final String? title;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  /// {@macro flutter.widgets.TransitionRoute.allowSnapshotting}
  final bool allowSnapshotting;

  final Completer<T?>? routeCompleter;

  /// Restoration ID to save and restore the state of the [Route] configured by
  /// this page.
  ///
  /// If no restoration ID is provided, the [Route] will not restore its state.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  /// Called after a pop on the associated route was handled.
  ///
  /// It's not possible to prevent the pop from happening at the time that this
  /// method is called; the pop has already happened. Use [canPop] to
  /// disable pops in advance.
  ///
  /// This will still be called even when the pop is canceled. A pop is canceled
  /// when the associated [Route.popDisposition] returns false, or when
  /// [canPop] is set to false. The `didPop` parameter indicates whether or not
  /// the back navigation actually happened successfully.
  final PopInvokedWithResultCallback<T>? onPopInvoked;

  /// When false, blocks the associated route from being popped.
  ///
  /// If this is set to false for first page in the Navigator. It prevents
  /// Flutter app from exiting.
  ///
  /// If there are any [PopScope] widgets in a route's widget subtree,
  /// each of their `canPop` must be `true`, in addition to this canPop, in
  /// order for the route to be able to pop.
  final bool canPop;

  const CupertinoPageFactory({
    this.title,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.allowSnapshotting = true,
    this.routeCompleter,
    this.restorationId,
    this.canPop = true,
    this.onPopInvoked,
  }) : super._();

  static void _defaultPopInvokedHandler(bool didPop, Object? result) {}

  @override
  Page<T> call(
    BuildContext context,
    RouteNode routeNode,
    LocalKey key,
    Widget child,
  ) =>
      ProxyCupertinoPage<T>(
        routeCompleter: routeCompleter,
        title: title,
        key: key,
        child: child,
        name: routeNode.route.id,
        arguments: routeNode.arguments,
        maintainState: maintainState,
        fullscreenDialog: fullscreenDialog,
        allowSnapshotting: allowSnapshotting,
        restorationId: restorationId,
        canPop: canPop,
        onPopInvoked: onPopInvoked ?? _defaultPopInvokedHandler,
      );
}

class ProxyCupertinoPage<T> extends CupertinoPage<T> {
  final Completer<T?>? routeCompleter;

  const ProxyCupertinoPage({
    required super.child,
    this.routeCompleter,
    super.name,
    super.arguments,
    super.key,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.title,
    super.restorationId,
    super.canPop,
    super.onPopInvoked,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    final route = super.createRoute(context);
    route.popped.then(
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
    return route;
  }
}
