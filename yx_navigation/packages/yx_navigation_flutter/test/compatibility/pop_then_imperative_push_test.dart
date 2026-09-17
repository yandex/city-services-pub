import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/base/builder/route_builder.dart';
import 'package:yx_navigation_flutter/src/base/declaration/route_declaration.dart';
import 'package:yx_navigation_flutter/src/config/navigation_config_provider.dart';
import 'package:yx_navigation_flutter/src/config/navigator_configuration.dart';
import 'package:yx_navigation_flutter/src/router/yx_router_config.dart';
import 'package:yx_navigation_flutter/yx_navigation_flutter_compatibility.dart';

import '../helpers/factories.dart';

abstract final class _Routes {
  static const home = YxRoute(id: 'home');
  static const details = YxRoute(id: 'details');
}

const _homeText = 'home-screen';
const _detailsText = 'details-screen';
const _imperativeText = 'imperative-screen';
const _replacementText = 'replacement-screen';

/// A Navigator 1.0 route, the kind legacy code pushes through a
/// `GlobalKey<NavigatorState>`.
MaterialPageRoute<void> _makeImperativeRoute() => MaterialPageRoute<void>(
      settings: const RouteSettings(name: _imperativeText),
      builder: (_) => const Text(_imperativeText),
    );

/// Same, but see-through, so a route underneath stays findable.
PageRouteBuilder<void> _makeReplacementRoute() => PageRouteBuilder<void>(
      settings: const RouteSettings(name: _replacementText),
      opaque: false,
      pageBuilder: (_, __, ___) => const Text(_replacementText),
    );

YxRouterConfig _makeConfig(GlobalKey<NavigatorState> navigatorKey) => makeSchema(
      initialNodeBuilder: (node) => node..setChildren([_Routes.home.toNode()]),
      declarations: [
        RouteDeclaration.routeBuilder(
          route: _Routes.home,
          routeBuilder: RouteBuilder.widget(
            builder: (_, __) => const Text(_homeText),
          ),
        ),
        RouteDeclaration.routeBuilder(
          route: _Routes.details,
          routeBuilder: RouteBuilder.widget(
            builder: (_, __) => const Text(_detailsText),
          ),
        ),
      ],
    ).build(
      navigatorConfiguration: NavigatorConfiguration(navigatorKey: navigatorKey),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('imperative route added right after a pop', () {
    /// A route added through the Navigator 1.0 API is pageless, and Flutter
    /// ties a pageless route to the page below it, removing them together.
    ///
    /// Tree mutations are synchronous while `Navigator.pages` is rebuilt on the
    /// next frame, so a route added in that window attaches to a page the tree
    /// has already dropped:
    ///
    /// ```text
    /// pop()     tree:  [ home ]            pages: [ home, details ]
    /// push()    the new pageless route attaches to `details`
    /// frame     `details` leaves `pages` and takes the route with it
    /// ```
    ///
    /// Crossing that boundary is what the compatibility layer is for, so the
    /// sequence is rejected rather than repaired.
    testWidgets('is rejected by an assert without compatibility',
        (tester) async {
      // arrange
      final navigatorKey = GlobalKey<NavigatorState>();
      final config = _makeConfig(navigatorKey);
      addTearDown(config.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: config));

      final controller = config.routerDelegate.stateManager;
      controller.push(_Routes.details);
      await tester.pumpAndSettle();
      expect(find.text(_detailsText), findsOneWidget);

      // act
      controller.pop();
      Object? caught;
      unawaited(
        navigatorKey.currentState!.push(_makeImperativeRoute()).catchError(
          (Object error) {
            caught = error;
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(caught, isAssertionError);
      expect(find.text(_imperativeText), findsNothing);
    });

    /// With the compatibility layer the imperative route is wrapped in a `Page`
    /// and joins the tree, so it is no longer tied to the outgoing page.
    testWidgets('arrives with compatibility enabled', (tester) async {
      // arrange
      final navigatorKey = GlobalKey<NavigatorState>();
      final config = _makeConfig(navigatorKey);
      addTearDown(config.dispose);

      await tester.pumpWidget(
        NavigationConfigProvider(
          navigatorOverrides: const NavigatorCompatibilityOverrides(),
          child: MaterialApp.router(routerConfig: config),
        ),
      );

      final controller = config.routerDelegate.stateManager;
      controller.push(_Routes.details);
      await tester.pumpAndSettle();
      expect(find.text(_detailsText), findsOneWidget);

      // act
      controller.pop();
      unawaited(navigatorKey.currentState!.push(_makeImperativeRoute()));
      await tester.pumpAndSettle();

      // assert
      expect(find.text(_detailsText), findsNothing);
      expect(find.text(_imperativeText), findsOneWidget);
    });

    /// Without a pending mutation the pages match the tree, so an imperative
    /// push is business as usual and the assert must not fire.
    testWidgets('works without compatibility when no pop precedes it',
        (tester) async {
      // arrange
      final navigatorKey = GlobalKey<NavigatorState>();
      final config = _makeConfig(navigatorKey);
      addTearDown(config.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: config));

      final controller = config.routerDelegate.stateManager;
      controller.push(_Routes.details);
      await tester.pumpAndSettle();

      // act
      unawaited(navigatorKey.currentState!.push(_makeImperativeRoute()));
      await tester.pumpAndSettle();

      // assert
      expect(tester.takeException(), isNull);
      expect(find.text(_imperativeText), findsOneWidget);
    });

    /// Replace operations normally assert on their own without the
    /// compatibility layer, but that assert only fires when the route being
    /// replaced is page-based. With a pageless route on top the operation goes
    /// through and hits this boundary instead.
    testWidgets('pushReplacement is rejected by an assert too', (tester) async {
      // arrange
      final navigatorKey = GlobalKey<NavigatorState>();
      final config = _makeConfig(navigatorKey);
      addTearDown(config.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: config));

      final controller = config.routerDelegate.stateManager;
      controller.push(_Routes.details);
      await tester.pumpAndSettle();

      // a pageless route on top of the details page
      unawaited(navigatorKey.currentState!.push(_makeImperativeRoute()));
      await tester.pumpAndSettle();
      expect(find.text(_imperativeText), findsOneWidget);

      // act
      controller.pop();
      Object? caught;
      unawaited(
        navigatorKey.currentState!
            .pushReplacement(_makeReplacementRoute())
            .catchError((Object error) {
          caught = error;
          return null;
        }),
      );
      await tester.pumpAndSettle();

      // assert
      expect(caught, isAssertionError);
      expect(find.text(_replacementText), findsNothing);
    });
  });
}
