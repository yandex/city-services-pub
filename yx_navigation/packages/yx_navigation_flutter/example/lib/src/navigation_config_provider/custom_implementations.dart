import 'package:flutter/material.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter.dart';

/// Transition delegate that disables animations.
class NoAnimationTransitionDelegate extends TransitionDelegate<Object?> {
  const NoAnimationTransitionDelegate();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final results = <RouteTransitionRecord>[];

    // Add every new route without animation.
    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }

    // Remove every exiting route without animation.
    for (final exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForComplete();
        final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final pagelessRoute in pagelessRoutes) {
            // Check state before calling markForComplete.
            if (pagelessRoute.isWaitingForExitingDecision) {
              pagelessRoute.markForComplete();
            }
          }
        }
      }
      results.add(exitingPageRoute);
    }

    return results;
  }
}

class FadeTransitionDelegate extends TransitionDelegate<Object?> {
  const FadeTransitionDelegate();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final results = <RouteTransitionRecord>[];

    // Add every new route with an enter animation.
    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        // markForPush produces an enter animation.
        pageRoute.markForPush();
      }
      results.add(pageRoute);
    }

    // Handle exiting routes with an exit animation.
    for (final exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        // markForPop produces an exit animation.
        exitingPageRoute.markForPop();

        final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final pagelessRoute in pagelessRoutes) {
            if (pagelessRoute.isWaitingForExitingDecision) {
              pagelessRoute.markForPop();
            }
          }
        }
      }
      results.add(exitingPageRoute);
    }

    return results;
  }
}

/// Custom page factory that applies a fade animation.
class FadePageFactory implements PageFactory<Object?> {
  const FadePageFactory();

  @override
  Page<Object?> call(
    BuildContext context,
    RouteNode routeNode,
    LocalKey key,
    Widget child,
  ) =>
      _FadePage<Object?>(
        key: key,
        name: routeNode.route.id,
        arguments: routeNode.arguments,
        child: child,
      );
}

/// Custom page with a fade animation.
class _FadePage<T> extends Page<T> {
  final Widget child;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Curve? reverseCurve;
  final bool maintainState;
  final bool fullscreenDialog;

  const _FadePage({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.curve = Curves.easeInOut,
    this.reverseCurve,
    this.maintainState = true,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) => _FadePageRoute<T>(
        page: this,
      );
}

// Route with a fade animation.
class _FadePageRoute<T> extends PageRoute<T> {
  _FadePageRoute({
    required _FadePage<T> page,
  }) : super(settings: page);

  // Important: use a getter so we always pick up the latest page from settings
  // when Flutter refreshes the Route via canUpdate.
  _FadePage<T> get _page => settings as _FadePage<T>;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  Duration get transitionDuration => _page.duration;

  @override
  Duration get reverseTransitionDuration =>
      _page.reverseDuration ?? _page.duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: _page.child,
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: _page.curve,
          reverseCurve: _page.reverseCurve ?? _page.curve,
        ),
        child: child,
      );
}

/// Custom widget builder with overridden NotFound and Empty widgets.
class CustomRouteNodeWidgetBuilder extends RouteNodeWidgetBuilder {
  const CustomRouteNodeWidgetBuilder();

  @override
  Widget toNotFoundWidget(BuildContext context, RouteNode routeNode) =>
      RouteNodeProvider(
        routeNode: routeNode,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Page not found'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Custom "Not Found" page',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This page was overridden via\nCustomRouteNodeWidgetBuilder',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget toEmptyWidget(BuildContext context, RouteNode routeNode) =>
      RouteNodeProvider(
        routeNode: routeNode,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Empty screen'),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.orange,
                ),
                SizedBox(height: 16),
                Text(
                  'Custom empty screen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This screen was overridden via\nCustomRouteNodeWidgetBuilder',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
