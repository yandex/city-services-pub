import 'package:flutter/widgets.dart';

/// {@template back_button_listenable_router}
/// A wrapper widget that handles system back button events for root [Router].
///
/// ## Purpose
///
/// When using YxNavigation with [MaterialApp.router], the root [Router]
/// needs to properly handle the system back button (Android hardware back,
/// iOS swipe gestures, etc.). This widget ensures back button events are
/// correctly dispatched to the router's [BackButtonDispatcher].
///
/// ## How It Works
///
/// The widget checks if there's a parent [Router] in the widget tree:
///
/// * **With parent Router**: Delegates back button handling to parent,
///   allowing nested routers to work correctly
///
/// * **Without parent Router (root)**: Wraps the router in [WillPopScope]
///   to intercept system back button events and forwards them to the
///   router's [BackButtonDispatcher]
///
/// ## Usage
///
/// This widget is typically used internally by YxNavigation and doesn't
/// need to be used directly by applications. However, it can be useful
/// when embedding YxNavigation routers in complex navigation hierarchies.
///
/// ```dart
/// BackButtonListenableRouter(
///   routerConfig: myRouterConfig,
/// )
/// ```
///
/// ## Behavior
///
/// When the system back button is pressed:
///
/// 1. Widget checks if [RouterConfig.backButtonDispatcher] exists
/// 2. If yes, invokes [BackButtonDispatcher.invokeCallback]
/// 3. If the dispatcher handles the event (returns `true`), prevents
///    system default behavior
/// 4. If not handled (returns `false`), allows system to close the app
///
/// This ensures proper integration with Flutter's declarative navigation
/// and allows routes to control whether back button should close the app
/// or navigate to a previous screen.
///
/// See also:
///
/// * [Router], the Flutter router this widget wraps
/// * [BackButtonDispatcher], which handles back button events
/// * [WillPopScope], the widget used for intercepting back button
/// {@endtemplate}
class BackButtonListenableRouter extends StatefulWidget {
  /// The router configuration to wrap.
  ///
  /// This configuration should include all router components:
  /// * [RouterConfig.routerDelegate]
  /// * [RouterConfig.routeInformationParser]
  /// * [RouterConfig.routeInformationProvider]
  /// * [RouterConfig.backButtonDispatcher]
  final RouterConfig routerConfig;

  /// {@macro back_button_listenable_router}
  const BackButtonListenableRouter({
    required this.routerConfig,
    super.key,
  });

  @override
  State<BackButtonListenableRouter> createState() =>
      _BackButtonListenableRouterState();
}

class _BackButtonListenableRouterState
    extends State<BackButtonListenableRouter> {
  /// The parent [Router] widget, if any.
  Router? parentRouter;

  /// Checks if there's a parent [BackButtonDispatcher] in the widget tree.
  ///
  /// If true, back button events will be handled by the parent router,
  /// and we don't need to wrap in [WillPopScope].
  bool get hasParentBackButtonDispatcher =>
      parentRouter?.backButtonDispatcher != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check for parent Router on every dependency change
    parentRouter = Router.maybeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final router = Router.withConfig(config: widget.routerConfig);

    // If there's a parent router, it will handle back button
    if (hasParentBackButtonDispatcher) {
      return router;
    }

    // Otherwise, we're the root router - handle back button ourselves
    return WillPopScope(
      onWillPop: () async {
        final backButtonDispatcher = widget.routerConfig.backButtonDispatcher;
        if (backButtonDispatcher != null) {
          // Ask the dispatcher if it handled the back button
          final didPop = await backButtonDispatcher.invokeCallback(
            Future<bool>.value(false),
          );

          if (didPop) {
            // Dispatcher handled it - don't let system close app
            return false;
          }
        }

        // Dispatcher didn't handle it - let system close app
        return true;
      },
      child: router,
    );
  }
}
