// WillPopScope is deprecated in favour of PopScope, but the production
// implementation of BackButtonListenableRouter still uses WillPopScope (see
// lib/src/compatibility/back_button_listenable_router.dart). These tests
// must reference the same API to assert the contract.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
// internal type, not exported
import 'package:yx_navigation_flutter/src/compatibility/back_button_listenable_router.dart';

import '../helpers/fallbacks.dart';

/// Minimal router delegate that does nothing — just keeps [Router.withConfig]
/// happy and renders an empty widget.
class _StubDelegate extends RouterDelegate<RouteNode> with ChangeNotifier {
  @override
  Future<bool> popRoute() async => false;

  @override
  Future<void> setNewRoutePath(RouteNode configuration) async {}

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// A router delegate whose build() renders the inner
/// [BackButtonListenableRouter]. Lets us host a nested router without
/// going through the `Router(child: ...)` ctor (which doesn't exist).
class _OuterDelegateHostingInner extends RouterDelegate<RouteNode>
    with ChangeNotifier {
  _OuterDelegateHostingInner({required this.innerConfig});

  final RouterConfig<RouteNode> innerConfig;

  @override
  Future<bool> popRoute() async => false;

  @override
  Future<void> setNewRoutePath(RouteNode configuration) async {}

  @override
  Widget build(BuildContext context) =>
      BackButtonListenableRouter(routerConfig: innerConfig);
}

/// Back button dispatcher spy. The `didPopFromCallback` controls what the
/// router-side callback returns when invoked; `invokeCalls` counts how many
/// times [invokeCallback] was called so tests can assert the "system back
/// goes through dispatcher" contract.
class _SpyDispatcher extends RootBackButtonDispatcher {
  _SpyDispatcher({this.didPopFromCallback = false});

  /// Result returned by the callback we pretend is registered on the
  /// dispatcher (i.e., what `Router` would install).
  bool didPopFromCallback;
  int invokeCalls = 0;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    invokeCalls++;
    return didPopFromCallback;
  }
}

void main() {
  setUpAll(registerFallbacks);

  group('BackButtonListenableRouter', () {
    testWidgets(
      'without parent Router: system back invokes dispatcher.invokeCallback',
      (tester) async {
        // arrange
        final dispatcher = _SpyDispatcher(didPopFromCallback: true);
        final stubDelegate = _StubDelegate();
        addTearDown(stubDelegate.dispose);
        final routerConfig = RouterConfig<RouteNode>(
          routerDelegate: stubDelegate,
          backButtonDispatcher: dispatcher,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: BackButtonListenableRouter(routerConfig: routerConfig),
          ),
        );

        // act
        final willPopScope =
            tester.widget<WillPopScope>(find.byType(WillPopScope));
        final result = await willPopScope.onWillPop!.call();

        // assert
        expect(dispatcher.invokeCalls, equals(1));
        // dispatcher handled it -> onWillPop returns false so the system does
        // NOT close the app.
        expect(result, isFalse);
      },
    );

    testWidgets(
      'onWillPop returns true when dispatcher did not handle the event',
      (tester) async {
        // arrange
        final dispatcher = _SpyDispatcher();
        final stubDelegate = _StubDelegate();
        addTearDown(stubDelegate.dispose);
        final routerConfig = RouterConfig<RouteNode>(
          routerDelegate: stubDelegate,
          backButtonDispatcher: dispatcher,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: BackButtonListenableRouter(routerConfig: routerConfig),
          ),
        );
        final willPopScope =
            tester.widget<WillPopScope>(find.byType(WillPopScope));

        // act
        final result = await willPopScope.onWillPop!.call();

        // assert: dispatcher returned false -> allow system default (close app)
        expect(dispatcher.invokeCalls, equals(1));
        expect(result, isTrue);
      },
    );

    testWidgets(
      'with parent Router: delegates to parent, does not wrap in WillPopScope',
      (tester) async {
        // arrange: outer Router provides its own BackButtonDispatcher, making
        // `hasParentBackButtonDispatcher == true` on the inner one. We wrap
        // the outer Router in a builder so we can reuse its BuildContext to
        // host a nested BackButtonListenableRouter.
        final innerStub = _StubDelegate();
        final outerHost = _OuterDelegateHostingInner(
          innerConfig: RouterConfig<RouteNode>(
            routerDelegate: innerStub,
            backButtonDispatcher: RootBackButtonDispatcher(),
          ),
        );
        addTearDown(innerStub.dispose);
        addTearDown(outerHost.dispose);
        final outerConfig = RouterConfig<RouteNode>(
          routerDelegate: outerHost,
          backButtonDispatcher: RootBackButtonDispatcher(),
        );

        // act
        await tester.pumpWidget(
          MaterialApp(
            home: Router<RouteNode>.withConfig(config: outerConfig),
          ),
        );

        // assert: inner BackButtonListenableRouter does NOT attach its own
        // WillPopScope. Look for any WillPopScope *below* the inner widget.
        final willPopScopeUnderInner = find.descendant(
          of: find.byType(BackButtonListenableRouter),
          matching: find.byType(WillPopScope),
        );
        expect(willPopScopeUnderInner, findsNothing);
      },
    );
  });
}
