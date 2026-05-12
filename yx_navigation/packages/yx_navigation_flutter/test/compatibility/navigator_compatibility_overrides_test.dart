import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/compatibility/compatibility_observer.dart';
import 'package:yx_navigation_flutter/src/compatibility/custom_route_page_factory_resolver.dart';
import 'package:yx_navigation_flutter/src/compatibility/navigator_compatibility_overrides.dart';
import 'package:yx_navigation_flutter/src/compatibility/route_node_compatibility_extension.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/fallbacks.dart';
import '../helpers/mocks.dart';

class _SpyObserver extends CompatibilityObserver {
  _SpyObserver({this.allow = true});

  final bool allow;
  int willPushCalls = 0;
  int didCreateCalls = 0;
  int didFailCalls = 0;
  Route<dynamic>? lastRoute;
  String? lastRouteId;

  @override
  bool willPushPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
  }) {
    willPushCalls++;
    lastRoute = route;
    lastRouteId = routeId;
    return allow;
  }

  @override
  void didCreatePagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required String routeId,
    required String routeType,
    required RouteNode routeNode,
  }) {
    didCreateCalls++;
  }

  @override
  void didFailPagelessRoute({
    required RouteNodeReadable routeNodeReadable,
    required Route<dynamic> route,
    required Object error,
    required RouteNode? routeNode,
  }) {
    didFailCalls++;
  }
}

Completer<Object?>? _popCompleter() => null;

void main() {
  setUpAll(registerFallbacks);

  group('NavigatorCompatibilityOverrides', () {
    test(
      'exposes a distinct non-null tear-off for each of '
      'push/pop/replace/removeRoute/pushAndRemoveUntil',
      () {
        // arrange
        const actualOverrides = NavigatorCompatibilityOverrides();

        // collect every tear-off into one list and make sure no two point
        // at the same function — catches regressions where e.g. `push`
        // accidentally returns the `pushReplacement` tear-off.
        final hooks = <Object?>[
          actualOverrides.push,
          actualOverrides.pop,
          actualOverrides.pushReplacement,
          actualOverrides.pushAndRemoveUntil,
          actualOverrides.removeRoute,
        ];

        // assert
        for (final hook in hooks) {
          expect(hook, isNotNull);
        }
        expect(hooks.toSet(), hasLength(hooks.length));
      },
    );

    test(
        'routeIdGenerator: equal settings -> equal ids; different settings '
        '-> different ids (contract, not format)', () {
      // arrange
      const actualOverrides = NavigatorCompatibilityOverrides();
      final a1 = MaterialPageRoute<Object?>(
        settings: const RouteSettings(name: 'details', arguments: 'args'),
        builder: (_) => const SizedBox.shrink(),
      );
      final a2 = MaterialPageRoute<Object?>(
        settings: const RouteSettings(name: 'details', arguments: 'args'),
        builder: (_) => const SizedBox.shrink(),
      );
      final b = MaterialPageRoute<Object?>(
        settings: const RouteSettings(name: 'other', arguments: 'args'),
        builder: (_) => const SizedBox.shrink(),
      );

      String generate(Route<Object?> r) => actualOverrides.routeIdGenerator(
            route: r,
            context: MockBuildContext(),
            navigator: _FakeNavigator(),
            navigationController: NavigationControllerMock(),
          );

      // act
      final idA1 = generate(a1);
      final idA2 = generate(a2);
      final idB = generate(b);

      // assert: same settings -> same id; different settings -> different id
      expect(idA1, equals(idA2));
      expect(idA1, isNot(equals(idB)));
    });

    test('routeIdGenerator fallback still produces a non-empty id when no name',
        () {
      // arrange
      const actualOverrides = NavigatorCompatibilityOverrides();
      final route = MaterialPageRoute<Object?>(
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      final actualId = actualOverrides.routeIdGenerator(
        route: route,
        context: MockBuildContext(),
        navigator: _FakeNavigator(),
        navigationController: NavigationControllerMock(),
      );

      // assert: contract — the fallback must still yield a non-empty id so
      // RouteNode can be created. The exact format (microseconds-since-
      // epoch) is an implementation detail and intentionally not pinned.
      expect(actualId, isNotEmpty);
    });

    test(
        'pop completes the last child completer with the result, leaving state intact',
        () async {
      // arrange
      const actualOverrides = NavigatorCompatibilityOverrides();
      final completer = Completer<Object?>();
      final route = MaterialPageRoute<Object?>(
        builder: (_) => const SizedBox.shrink(),
      );
      final pagelessChild = RouteNode.fromRoute(
        route: const YxRoute(id: 'pageless'),
        extra: {
          NavigatorCompatibilityOverrides.routeExtraKey: route,
          NavigatorCompatibilityOverrides.routeIdExtraKey: 'pageless',
          NavigatorCompatibilityOverrides.completerExtraKey: completer,
        },
      );
      final parent = RouteNode.fromRoute(
        route: const YxRoute(id: 'root'),
        children: [pagelessChild],
      );
      final controller = NavigationControllerMock();
      when(() => controller.state).thenReturn(parent);

      // act
      actualOverrides.pop!<String>(
        context: MockBuildContext(),
        navigator: _FakeNavigator(),
        navigationController: controller,
        result: 'done',
      );

      // assert
      expect(completer.isCompleted, isTrue);
      expect(await completer.future, equals('done'));
    });

    testWidgets('push pushes a pageless node with Material page factory',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final pushed = <RouteNode>[];
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer(
        (invocation) =>
            pushed.add(invocation.positionalArguments[0] as RouteNode),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'detail'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      final actualFuture = actualOverrides.push!<String>(
        route: route,
        context: tester.element(find.byType(Scaffold)),
        navigator: _FakeNavigator(),
        popCompleterProvider: _popCompleter,
        navigationController: controller,
      );

      // assert
      expect(pushed, hasLength(1));
      final node = pushed.single;
      expect(node.isPageBased, isFalse);
      // The native name is produced by the default routeIdGenerator; its
      // exact format is not part of the public contract (separate tests
      // lock the equality semantics).
      expect(node.nativeName, isNotEmpty);
      expect(node.nativeRoute, same(route));
      expect(node.pageFactory, isA<ProxyMaterialPage>());
      expect(actualFuture, isA<Future<String?>>());
    });

    testWidgets('push for CupertinoPageRoute yields cupertino page factory',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final pushed = <RouteNode>[];
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer(
        (invocation) =>
            pushed.add(invocation.positionalArguments[0] as RouteNode),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = CupertinoPageRoute<String>(
        settings: const RouteSettings(name: 'cupertino'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
      );

      // assert
      expect(pushed.single.pageFactory, isA<ProxyCupertinoPage>());
    });

    testWidgets('push notifies observer lifecycle hooks on success',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      final observer = _SpyObserver();
      final actualOverrides =
          NavigatorCompatibilityOverrides(observer: observer);
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer((_) {});
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'detail'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
      );

      // assert
      expect(observer.willPushCalls, equals(1));
      expect(observer.didCreateCalls, equals(1));
      expect(observer.lastRoute, same(route));
      // Route id is produced by the installed `routeIdGenerator`; its exact
      // format is not part of the public contract, so assert that *some* id
      // was assigned. Format stability (equal settings → equal ids,
      // differing settings → differing ids) is covered by the id-generator
      // tests above.
      expect(observer.lastRouteId, isNotEmpty);
    });

    testWidgets('push throws UnsupportedRouteException when observer blocks it',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      final observer = _SpyObserver(allow: false);
      final actualOverrides =
          NavigatorCompatibilityOverrides(observer: observer);
      final controller = NavigationControllerMock();
      final route = MaterialPageRoute<String>(
        builder: (_) => const SizedBox.shrink(),
      );

      // act/assert
      expect(
        () => actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
        throwsA(isA<UnsupportedRouteException>()),
      );
    });

    testWidgets(
        'pushReplacement mutation callback upserts last child with the new '
        'pageless node', (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final controller = NavigationControllerMock();
      when(() => controller.mutate(any())).thenAnswer(
        (_) => RouteNode.fromRoute(route: const YxRoute(id: 'after')),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'replace'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.pushReplacement!<String, Object>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
          result: null,
        ),
      );

      // capture the mutation callback and apply it to a known initial tree
      // (one existing child 'old-last' which must be replaced in place).
      final captured = verify(() => controller.mutate(captureAny()))
          .captured
          .single as MutateNodeCallback;
      final initial = RouteNode.fromRoute(
        route: const YxRoute(id: 'root'),
        children: [
          RouteNode.fromRoute(route: const YxRoute(id: 'old-last')),
        ],
      ).toMutable();
      captured(initial);

      // assert: upsertLast replaced the single existing child.
      expect(initial.children, hasLength(1));
      expect(initial.children.single.nativeRoute, same(route));
      expect(initial.children.single.nativeName, isNotEmpty);
    });

    testWidgets(
        'pushAndRemoveUntil mutation callback wipes everything under predicate '
        'and appends the new pageless node', (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final controller = NavigationControllerMock();
      when(() => controller.mutate(any())).thenAnswer(
        (_) => RouteNode.fromRoute(route: const YxRoute(id: 'after')),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'replace'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.pushAndRemoveUntil!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
          // predicate that always returns false — internal _wrapRoutePredicate
          // additionally filters page-based and null-route nodes, so every
          // pageless child must be removed.
          predicate: (_) => false,
        ),
      );

      // capture & apply on a known initial tree of two pageless children.
      final captured = verify(() => controller.mutate(captureAny()))
          .captured
          .single as MutateNodeCallback;

      final olderRoute = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'older'),
        builder: (_) => const SizedBox.shrink(),
      );
      final initial = RouteNode.fromRoute(
        route: const YxRoute(id: 'root'),
        children: [
          RouteNode.fromRoute(
            route: const YxRoute(id: 'older'),
            extra: <String, Object?>{
              NavigatorCompatibilityOverrides.routeExtraKey: olderRoute,
              NavigatorCompatibilityOverrides.routeIdExtraKey: 'older()',
            },
          ),
        ],
      ).toMutable();
      captured(initial);

      // assert: only the newly pushed node remains.
      expect(initial.children, hasLength(1));
      expect(initial.children.single.nativeRoute, same(route));
      expect(initial.children.single.nativeName, isNotEmpty);
    });

    test(
        'removeRoute mutation callback drops the child whose nativeRoute '
        'matches, while preserving the sibling', () {
      // arrange
      const actualOverrides = NavigatorCompatibilityOverrides();
      final controller = NavigationControllerMock();
      when(() => controller.mutate(any())).thenAnswer(
        (_) => RouteNode.fromRoute(route: const YxRoute(id: 'after')),
      );
      final targetRoute = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'target'),
        builder: (_) => const SizedBox.shrink(),
      );
      final keepRoute = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'keep'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      actualOverrides.removeRoute!(
        route: targetRoute,
        context: MockBuildContext(),
        navigator: _FakeNavigator(),
        navigationController: controller,
        result: null,
      );

      // capture & apply on a tree with two pageless children — only the one
      // whose nativeRoute == targetRoute must disappear. The internal
      // predicate additionally requires children.length > 1, so leaving
      // a single sibling is essential.
      final captured = verify(() => controller.mutate(captureAny()))
          .captured
          .single as MutateNodeCallback;
      final initial = RouteNode.fromRoute(
        route: const YxRoute(id: 'root'),
        children: [
          RouteNode.fromRoute(
            route: const YxRoute(id: 'keep'),
            extra: <String, Object?>{
              NavigatorCompatibilityOverrides.routeExtraKey: keepRoute,
              NavigatorCompatibilityOverrides.routeIdExtraKey: 'keep()',
            },
          ),
          RouteNode.fromRoute(
            route: const YxRoute(id: 'target'),
            extra: <String, Object?>{
              NavigatorCompatibilityOverrides.routeExtraKey: targetRoute,
              NavigatorCompatibilityOverrides.routeIdExtraKey: 'target()',
            },
          ),
        ],
      ).toMutable();
      captured(initial);

      // assert: the target child was removed, sibling preserved.
      expect(initial.children, hasLength(1));
      expect(initial.children.single.nativeRoute, same(keepRoute));
    });

    testWidgets('push for ModalBottomSheetRoute yields modal bottom sheet page',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final pushed = <RouteNode>[];
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer(
        (invocation) =>
            pushed.add(invocation.positionalArguments[0] as RouteNode),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = ModalBottomSheetRoute<String>(
        builder: (_) => const SizedBox.shrink(),
        isScrollControlled: true,
      );

      // act
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
      );

      // assert
      expect(pushed.single.pageFactory, isA<ModalBottomSheetPage<String>>());
    });

    testWidgets('push for DialogRoute yields a DialogRoutePage',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final pushed = <RouteNode>[];
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer(
        (invocation) =>
            pushed.add(invocation.positionalArguments[0] as RouteNode),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final context = tester.element(find.byType(Scaffold));
      final route = DialogRoute<String>(
        context: context,
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: context,
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
      );

      // assert
      expect(pushed.single.pageFactory, isA<DialogRoutePage<String>>());
    });

    testWidgets(
        'push for CupertinoDialogRoute yields a CupertinoDialogRoutePage',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final pushed = <RouteNode>[];
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer(
        (invocation) =>
            pushed.add(invocation.positionalArguments[0] as RouteNode),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final context = tester.element(find.byType(Scaffold));
      final route = CupertinoDialogRoute<String>(
        context: context,
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: context,
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
      );

      // assert
      expect(
        pushed.single.pageFactory,
        isA<CupertinoDialogRoutePage<String>>(),
      );
    });

    testWidgets('push for CupertinoModalPopupRoute yields popup page factory',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final pushed = <RouteNode>[];
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer(
        (invocation) =>
            pushed.add(invocation.positionalArguments[0] as RouteNode),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = CupertinoModalPopupRoute<String>(
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
      );

      // assert
      expect(
        pushed.single.pageFactory,
        isA<CupertinoModalPopupRoutePage<String>>(),
      );
    });

    testWidgets('push for RawDialogRoute yields raw dialog page factory',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final pushed = <RouteNode>[];
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer(
        (invocation) =>
            pushed.add(invocation.positionalArguments[0] as RouteNode),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = RawDialogRoute<String>(
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
      );

      // assert
      expect(
        pushed.single.pageFactory,
        isA<RawDialogRoutePage<String>>(),
      );
    });

    testWidgets(
        'push for custom ModalRoute falls back to modalRouteProxy page factory',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final pushed = <RouteNode>[];
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer(
        (invocation) =>
            pushed.add(invocation.positionalArguments[0] as RouteNode),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = PageRouteBuilder<String>(
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
      );

      // assert
      expect(
        pushed.single.pageFactory,
        isA<ModalRouteProxyPage<String>>(),
      );
    });

    testWidgets('push with custom resolver uses custom page factory resolver',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const expectedKey = ValueKey<String>('custom-resolver');
      const customPage = MaterialPage<Object?>(
        key: expectedKey,
        child: SizedBox.shrink(),
      );
      const resolver = _StubCustomResolver(page: customPage);
      const actualOverrides = NavigatorCompatibilityOverrides(
        customRoutePageFactoryResolver: resolver,
      );
      final pushed = <RouteNode>[];
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer(
        (invocation) =>
            pushed.add(invocation.positionalArguments[0] as RouteNode),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = MaterialPageRoute<String>(
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
      );

      // assert
      expect(pushed.single.pageFactory, same(customPage));
    });

    testWidgets(
        'push for PopupRoute without specialized adapter throws UnsupportedRouteException',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final controller = NavigationControllerMock();
      final route = _StubPopupRoute<String>();

      // act/assert
      expect(
        () => actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        ),
        throwsA(isA<UnsupportedRouteException>()),
      );
    });

    testWidgets(
        'push awaits popCompleter.future before pushing (ordering contract)',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final controller = NavigationControllerMock();
      when(() => controller.pushNode(any())).thenAnswer((_) {});
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final popCompleter = Completer<Object?>();
      final route = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'detail'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act: kick off push while popCompleter is still pending.
      unawaited(
        actualOverrides.push!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: () => popCompleter,
          navigationController: controller,
        ),
      );

      // The push future must be suspended on popCompleter.future — so
      // nothing should have been pushed yet.
      await tester.pump();
      verifyNever(() => controller.pushNode(any()));

      // Complete the pop gate and let microtasks run.
      popCompleter.complete();
      await tester.pump();

      // assert: push proceeded exactly once after the gate opened.
      verify(() => controller.pushNode(any())).called(1);
    });

    testWidgets(
        'pushReplacement awaits popCompleter.future before mutating state',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final controller = NavigationControllerMock();
      when(() => controller.mutate(any())).thenAnswer(
        (_) => RouteNode.fromRoute(route: const YxRoute(id: 'after')),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final popCompleter = Completer<Object?>();
      final route = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'replace'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.pushReplacement!<String, Object>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: () => popCompleter,
          navigationController: controller,
          result: null,
        ),
      );

      await tester.pump();
      verifyNever(() => controller.mutate(any()));

      popCompleter.complete();
      await tester.pump();

      // assert
      verify(() => controller.mutate(any())).called(1);
    });

    testWidgets(
        'pushAndRemoveUntil awaits popCompleter.future before mutating state',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final controller = NavigationControllerMock();
      when(() => controller.mutate(any())).thenAnswer(
        (_) => RouteNode.fromRoute(route: const YxRoute(id: 'after')),
      );
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final popCompleter = Completer<Object?>();
      final route = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'new'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      unawaited(
        actualOverrides.pushAndRemoveUntil!<String>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: () => popCompleter,
          navigationController: controller,
          predicate: (_) => false,
        ),
      );

      await tester.pump();
      verifyNever(() => controller.mutate(any()));

      popCompleter.complete();
      await tester.pump();

      // assert
      verify(() => controller.mutate(any())).called(1);
    });

    testWidgets(
        '_attachPageFactory error path: completer error is reported to '
        'FlutterError.onError and source route popped future resolves to null',
        (tester) async {
      // arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      const actualOverrides = NavigatorCompatibilityOverrides();
      final controller = NavigationControllerMock();
      final capturedCompleters = <Completer<Object?>>[];
      when(() => controller.pushNode(any())).thenAnswer((invocation) {
        final node = invocation.positionalArguments[0] as RouteNode;
        final completer =
            node.extra[NavigatorCompatibilityOverrides.completerExtraKey]!
                as Completer<Object?>;
        capturedCompleters.add(completer);
      });
      when(() => controller.state).thenReturn(
        RouteNode.fromRoute(route: const YxRoute(id: 'root')),
      );
      final route = MaterialPageRoute<Object?>(
        settings: const RouteSettings(name: 'errorable'),
        builder: (_) => const SizedBox.shrink(),
      );

      // intercept FlutterError reports from within the assert-guarded
      // onError callback in _attachPageFactory.
      final originalOnError = FlutterError.onError;
      final collectedErrors = <FlutterErrorDetails>[];
      FlutterError.onError = collectedErrors.add;

      try {
        // act: kick off push and swallow the expected thrown error from the
        // returned future (routeCompleter.future — same completer we error).
        final future = actualOverrides.push!<Object?>(
          route: route,
          context: tester.element(find.byType(Scaffold)),
          navigator: _FakeNavigator(),
          popCompleterProvider: _popCompleter,
          navigationController: controller,
        );
        // attach error handler so the framework doesn't surface the error as
        // a test failure.
        unawaited(future.catchError((Object _) => null));

        capturedCompleters.single.completeError(Exception('boom'));
        await tester.pump();

        // assert: source route's `popped` future resolved with null — not
        // with the thrown exception — thanks to the onError fallback in
        // _attachPageFactory that calls sourceRouteCompleter.complete(null).
        expect(await route.popped, isNull);

        // assert: FlutterError.reportError was invoked with our exception.
        // (Only in debug/assert mode; guard so release builds still pass.)
        assert(() {
          expect(collectedErrors, isNotEmpty);
          expect(
            collectedErrors.first.exception,
            isA<Exception>(),
          );
          return true;
        }(), '');
      } finally {
        FlutterError.onError = originalOnError;
      }
    });

    test(
        'removeRoute: guard refuses to leave parent with zero children '
        '(last-remaining-child preserved)', () {
      // arrange
      const actualOverrides = NavigatorCompatibilityOverrides();
      final controller = NavigationControllerMock();
      when(() => controller.mutate(any())).thenAnswer(
        (_) => RouteNode.fromRoute(route: const YxRoute(id: 'after')),
      );
      final soleRoute = MaterialPageRoute<String>(
        settings: const RouteSettings(name: 'sole'),
        builder: (_) => const SizedBox.shrink(),
      );

      // act
      actualOverrides.removeRoute!(
        route: soleRoute,
        context: MockBuildContext(),
        navigator: _FakeNavigator(),
        navigationController: controller,
        result: null,
      );

      // capture the mutation and apply to a tree where the child we're
      // trying to remove is the ONLY child. Impl predicate:
      //     !isPageBased && nativeRoute == route && children.length > 1
      // -> length == 1 short-circuits to false, so the child survives.
      final captured = verify(() => controller.mutate(captureAny()))
          .captured
          .single as MutateNodeCallback;
      final initial = RouteNode.fromRoute(
        route: const YxRoute(id: 'root'),
        children: [
          RouteNode.fromRoute(
            route: const YxRoute(id: 'sole'),
            extra: <String, Object?>{
              NavigatorCompatibilityOverrides.routeExtraKey: soleRoute,
              NavigatorCompatibilityOverrides.routeIdExtraKey: 'sole()',
            },
          ),
        ],
      ).toMutable();
      captured(initial);

      // assert: the last-remaining child was NOT removed.
      expect(initial.children, hasLength(1));
      expect(initial.children.single.nativeRoute, same(soleRoute));
    });
  });
}

class _StubCustomResolver extends CustomRoutePageFactoryResolver {
  const _StubCustomResolver({required this.page});

  final Page<Object?> page;

  @override
  bool hasResolverFor<T>(Route<T> route) => true;

  @override
  Page<Object?> resolvePage<T>({
    required Completer<T?> routeCompleter,
    required Route<T> route,
    required LocalKey key,
  }) =>
      page;
}

class _StubPopupRoute<T> extends PopupRoute<T> {
  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      const SizedBox.shrink();
}

/// Minimal NavigatorState stub. We never call any of its methods — overrides
/// merely pass it through.
class _FakeNavigator extends Fake implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      '_FakeNavigator';
}
