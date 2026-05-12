import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation/yx_navigation.dart';
// internal type, not exported
import 'package:yx_navigation_flutter/src/compatibility/navigator_compatibility_overrides.dart';
// internal extension exposed only via deep import
import 'package:yx_navigation_flutter/src/compatibility/route_node_compatibility_extension.dart';

import '../helpers/factories.dart';
import '../helpers/fallbacks.dart';

RouteNode _pagelessNode({
  required String routeId,
  required Route<Object?> route,
  Page<Object?>? page,
  Completer<Object?>? completer,
  Object? arguments,
}) {
  final extra = <String, Object?>{
    NavigatorCompatibilityOverrides.routeExtraKey: route,
    NavigatorCompatibilityOverrides.routeIdExtraKey: routeId,
    NavigatorCompatibilityOverrides.argumentsExtraKey: arguments,
  };
  if (page != null) {
    extra[NavigatorCompatibilityOverrides.pageFactoryExtraKey] = page;
  }
  if (completer != null) {
    extra[NavigatorCompatibilityOverrides.completerExtraKey] = completer;
  }
  return RouteNode.fromRoute(
    route: YxRoute(id: routeId),
    extra: extra,
  );
}

void main() {
  setUpAll(registerFallbacks);

  group('RouteNodeCompatibilityExtension', () {
    test('isPageBased is true for declarative nodes without route extra', () {
      // arrange
      final actualNode = makeNode();

      // assert
      expect(actualNode.isPageBased, isTrue);
    });

    test('isPageBased is false when node has route extra key', () {
      // arrange
      final actualRoute = MaterialPageRoute<Object?>(
        builder: (_) => const SizedBox.shrink(),
      );
      final actualNode = _pagelessNode(
        routeId: 'r1',
        route: actualRoute,
      );

      // assert
      expect(actualNode.isPageBased, isFalse);
    });

    test('nativeRoute returns stored route for pageless nodes', () {
      // arrange
      final expectedRoute = MaterialPageRoute<Object?>(
        builder: (_) => const SizedBox.shrink(),
      );
      final actualNode = _pagelessNode(
        routeId: 'r1',
        route: expectedRoute,
      );

      // assert
      expect(actualNode.nativeRoute, same(expectedRoute));
    });

    test('nativeRoute is null for page-based nodes', () {
      // arrange
      final actualNode = makeNode();

      // assert
      expect(actualNode.nativeRoute, isNull);
    });

    test('nativeName returns stored id for pageless nodes', () {
      // arrange
      final actualNode = _pagelessNode(
        routeId: 'stored-id',
        route: MaterialPageRoute<Object?>(
          builder: (_) => const SizedBox.shrink(),
        ),
      );

      // assert
      expect(actualNode.nativeName, equals('stored-id'));
    });

    test('nativeName returns route.id for page-based nodes', () {
      // arrange
      final actualNode = makeNode(route: makeRoute(id: 'page'));

      // assert
      expect(actualNode.nativeName, equals('page'));
    });

    test('nativeArguments returns stored arguments for pageless nodes', () {
      // arrange
      const expectedArguments = {'key': 'value'};
      final actualNode = _pagelessNode(
        routeId: 'r',
        route: MaterialPageRoute<Object?>(
          builder: (_) => const SizedBox.shrink(),
        ),
        arguments: expectedArguments,
      );

      // assert
      expect(actualNode.nativeArguments, equals(expectedArguments));
    });

    test('nativeArguments is null for page-based nodes', () {
      // arrange
      final actualNode = makeNode();

      // assert
      expect(actualNode.nativeArguments, isNull);
    });

    test('pageFactory returns stored page for pageless nodes', () {
      // arrange
      const expectedPage = MaterialPage<Object?>(child: SizedBox.shrink());
      final actualNode = _pagelessNode(
        routeId: 'r',
        route: MaterialPageRoute<Object?>(
          builder: (_) => const SizedBox.shrink(),
        ),
        page: expectedPage,
      );

      // assert
      expect(actualNode.pageFactory, same(expectedPage));
    });

    test('pageFactory is null for page-based nodes', () {
      // arrange
      final actualNode = makeNode();

      // assert
      expect(actualNode.pageFactory, isNull);
    });

    test('resultCompleter returns stored completer for pageless nodes', () {
      // arrange
      final expectedCompleter = Completer<Object?>();
      final actualNode = _pagelessNode(
        routeId: 'r',
        route: MaterialPageRoute<Object?>(
          builder: (_) => const SizedBox.shrink(),
        ),
        completer: expectedCompleter,
      );

      // assert
      expect(actualNode.resultCompleter, same(expectedCompleter));
    });

    test('resultCompleter is null for page-based nodes', () {
      // arrange
      final actualNode = makeNode();

      // assert
      expect(actualNode.resultCompleter, isNull);
    });
  });
}
