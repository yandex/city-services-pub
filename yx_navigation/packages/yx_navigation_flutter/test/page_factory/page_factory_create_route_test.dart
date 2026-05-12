import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/compatibility/source_route_completer.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/fallbacks.dart';

Future<T> _runWithContext<T>(
  WidgetTester tester,
  T Function(BuildContext context) body,
) async {
  late T result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          result = body(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return result;
}

void main() {
  setUpAll(registerFallbacks);

  group('page factory createRoute paths', () {
    testWidgets('ProxyMaterialPage.createRoute completes routeCompleter on pop',
        (tester) async {
      // arrange
      final completer = Completer<String?>();
      final page = ProxyMaterialPage<String>(
        routeCompleter: completer,
        child: const SizedBox.shrink(),
      );

      // act
      final route =
          await _runWithContext(tester, (context) => page.createRoute(context));

      // assert
      expect(route, isA<ModalRoute<String>>());
      // Trigger the popped future to resolve via didComplete
      SourceRouteCompleter<String>(route).complete('ok');
      await tester.pump();
      expect(completer.isCompleted, isTrue);
      expect(await completer.future, equals('ok'));
    });

    testWidgets(
        'ProxyCupertinoPage.createRoute completes routeCompleter on pop',
        (tester) async {
      // arrange
      final completer = Completer<String?>();
      final page = ProxyCupertinoPage<String>(
        routeCompleter: completer,
        child: const SizedBox.shrink(),
      );

      // act
      final route =
          await _runWithContext(tester, (context) => page.createRoute(context));

      // assert
      expect(route, isA<ModalRoute<String>>());
      SourceRouteCompleter<String>(route).complete('cupertino-ok');
      await tester.pump();
      expect(await completer.future, equals('cupertino-ok'));
    });

    testWidgets('ModalBottomSheetPage.createRoute completes routeCompleter',
        (tester) async {
      // arrange
      final completer = Completer<String?>();
      final page = ModalBottomSheetPage<String>(
        builder: (_) => const SizedBox.shrink(),
        isScrollControlled: true,
        routeCompleter: completer,
      );

      // act
      final route =
          await _runWithContext(tester, (context) => page.createRoute(context));

      // assert
      expect(route, isA<ModalBottomSheetRoute<String>>());
      SourceRouteCompleter<String>(route).complete('sheet-ok');
      await tester.pump();
      expect(await completer.future, equals('sheet-ok'));
    });

    testWidgets(
        'ModalRouteProxyPage.createRoute returns source route as-is for PopupRoute',
        (tester) async {
      // arrange
      final completer = Completer<String?>();
      final sourceRoute = _StubPopupRoute<String>();
      final page = ModalRouteProxyPage<String>(
        route: sourceRoute,
        routeCompleter: completer,
      );

      // act
      final route =
          await _runWithContext(tester, (context) => page.createRoute(context));

      // assert
      expect(route, same(sourceRoute));
      SourceRouteCompleter<String>(route).complete('popup-source-ok');
      await tester.pump();
      expect(await completer.future, equals('popup-source-ok'));
    });

    testWidgets('DialogRoutePage.createRoute builds a DialogRoute',
        (tester) async {
      // arrange
      final completer = Completer<String?>();

      // act
      final route = await _runWithContext(tester, (context) {
        final sourceRoute = DialogRoute<String>(
          context: context,
          builder: (_) => const SizedBox.shrink(),
        );
        final page = DialogRoutePage<String>(
          route: sourceRoute,
          barrierDismissible: true,
          useSafeArea: true,
          routeCompleter: completer,
        );
        return page.createRoute(context);
      });

      // assert
      expect(route, isA<DialogRoute<String>>());
      SourceRouteCompleter<String>(route).complete('dialog-ok');
      await tester.pump();
      expect(await completer.future, equals('dialog-ok'));
    });

    testWidgets(
        'CupertinoDialogRoutePage.createRoute builds a CupertinoDialogRoute',
        (tester) async {
      // arrange
      final completer = Completer<String?>();

      // act
      final route = await _runWithContext(tester, (context) {
        final sourceRoute = CupertinoDialogRoute<String>(
          context: context,
          builder: (_) => const SizedBox.shrink(),
        );
        final page = CupertinoDialogRoutePage<String>(
          route: sourceRoute,
          barrierDismissible: false,
          routeCompleter: completer,
        );
        return page.createRoute(context);
      });

      // assert
      expect(route, isA<CupertinoDialogRoute<String>>());
      SourceRouteCompleter<String>(route).complete('c-dialog-ok');
      await tester.pump();
      expect(await completer.future, equals('c-dialog-ok'));
    });

    testWidgets(
        'CupertinoModalPopupRoutePage.createRoute builds a CupertinoModalPopupRoute',
        (tester) async {
      // arrange
      final completer = Completer<String?>();

      // act
      final route = await _runWithContext(tester, (context) {
        final sourceRoute = CupertinoModalPopupRoute<String>(
          builder: (_) => const SizedBox.shrink(),
        );
        final page = CupertinoModalPopupRoutePage<String>(
          route: sourceRoute,
          barrierDismissible: true,
          semanticsDismissible: true,
          routeCompleter: completer,
        );
        return page.createRoute(context);
      });

      // assert
      expect(route, isA<CupertinoModalPopupRoute<String>>());
      SourceRouteCompleter<String>(route).complete('popup-ok');
      await tester.pump();
      expect(await completer.future, equals('popup-ok'));
    });

    testWidgets('RawDialogRoutePage.createRoute builds a RawDialogRoute',
        (tester) async {
      // arrange
      final completer = Completer<String?>();

      // act
      final route = await _runWithContext(tester, (context) {
        final sourceRoute = RawDialogRoute<String>(
          pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        );
        final page = RawDialogRoutePage<String>(
          route: sourceRoute,
          barrierDismissible: true,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 100),
          routeCompleter: completer,
        );
        return page.createRoute(context);
      });

      // assert
      expect(route, isA<RawDialogRoute<String>>());
      SourceRouteCompleter<String>(route).complete('raw-ok');
      await tester.pump();
      expect(await completer.future, equals('raw-ok'));
    });
  });
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
