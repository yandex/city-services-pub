import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yx_navigation/yx_navigation.dart';
import 'package:yx_navigation_flutter/src/router/active_route_controller_provider.dart';

import '../helpers/fallbacks.dart';

class _ControllerMock extends Mock implements ActiveRouteController {}

void main() {
  setUpAll(registerFallbacks);

  group('ActiveRouteControllerProvider', () {
    testWidgets('controllerOf returns provided controller', (tester) async {
      // arrange
      final expectedController = _ControllerMock();
      ActiveRouteController? actualController;

      // act
      await tester.pumpWidget(
        ActiveRouteControllerProvider(
          controller: expectedController,
          child: Builder(
            builder: (context) {
              actualController =
                  ActiveRouteControllerProvider.controllerOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualController, same(expectedController));
    });

    testWidgets('controllerMaybeOf returns null when provider is absent',
        (tester) async {
      // arrange
      ActiveRouteController? actualController;

      // act
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            actualController =
                ActiveRouteControllerProvider.controllerMaybeOf(context);
            return const SizedBox.shrink();
          },
        ),
      );

      // assert
      expect(actualController, isNull);
    });

    testWidgets('controllerOf throws when provider is absent', (tester) async {
      // arrange
      Object? caughtError;

      // act
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            try {
              ActiveRouteControllerProvider.controllerOf(context);
            } on Object catch (e) {
              caughtError = e;
            }
            return const SizedBox.shrink();
          },
        ),
      );

      // assert
      expect(caughtError, isA<ArgumentError>());
    });

    testWidgets(
        'controllerOf reflects updated controller when ValueNotifier value '
        'changes', (tester) async {
      // arrange
      final firstController = _ControllerMock();
      final secondController = _ControllerMock();
      final controllerNotifier =
          ValueNotifier<ActiveRouteController>(firstController);
      addTearDown(controllerNotifier.dispose);
      ActiveRouteController? lastObservedController;

      await tester.pumpWidget(
        ValueListenableBuilder<ActiveRouteController>(
          valueListenable: controllerNotifier,
          builder: (context, controller, _) => ActiveRouteControllerProvider(
            controller: controller,
            child: Builder(
              builder: (context) {
                lastObservedController =
                    ActiveRouteControllerProvider.controllerOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // assert
      expect(lastObservedController, same(firstController));

      // act
      controllerNotifier.value = secondController;
      await tester.pump();

      // assert
      expect(lastObservedController, same(secondController));
    });

    testWidgets(
        'controllerMaybeOf with listen false returns same controller as '
        'listen true', (tester) async {
      // arrange
      final controller = _ControllerMock();
      ActiveRouteController? withListen;
      ActiveRouteController? withoutListen;

      // act
      await tester.pumpWidget(
        ActiveRouteControllerProvider(
          controller: controller,
          child: Builder(
            builder: (context) {
              withListen = ActiveRouteControllerProvider.controllerMaybeOf(
                context,
              );
              withoutListen = ActiveRouteControllerProvider.controllerMaybeOf(
                context,
                listen: false,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(withListen, same(controller));
      expect(withoutListen, same(controller));
    });
  });

  group('ActiveRouteControllerProvider.branch', () {
    const expectedRoute = YxRoute(id: 'branch');

    testWidgets('branchRouteMaybeOf returns provided route', (tester) async {
      // arrange
      YxRoute? actualRoute;

      // act
      await tester.pumpWidget(
        ActiveRouteControllerProvider.branch(
          route: expectedRoute,
          child: Builder(
            builder: (context) {
              actualRoute =
                  ActiveRouteControllerProvider.branchRouteMaybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualRoute, same(expectedRoute));
    });

    testWidgets(
        'branchRouteMaybeOf returns null when branch provider is absent',
        (tester) async {
      // arrange
      YxRoute? actualRoute;

      // act
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            actualRoute =
                ActiveRouteControllerProvider.branchRouteMaybeOf(context);
            return const SizedBox.shrink();
          },
        ),
      );

      // assert
      expect(actualRoute, isNull);
    });

    testWidgets(
        'branchRouteMaybeOf returns null under controller-only provider',
        (tester) async {
      // arrange
      YxRoute? actualRoute;

      // act
      await tester.pumpWidget(
        ActiveRouteControllerProvider(
          controller: _ControllerMock(),
          child: Builder(
            builder: (context) {
              actualRoute =
                  ActiveRouteControllerProvider.branchRouteMaybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualRoute, isNull);
    });

    testWidgets('controllerMaybeOf returns null under branch-only provider',
        (tester) async {
      // arrange
      ActiveRouteController? actualController;

      // act
      await tester.pumpWidget(
        ActiveRouteControllerProvider.branch(
          route: expectedRoute,
          child: Builder(
            builder: (context) {
              actualController =
                  ActiveRouteControllerProvider.controllerMaybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualController, isNull);
    });

    testWidgets('controllerOf throws under branch-only provider',
        (tester) async {
      // arrange
      Object? caughtError;

      // act
      await tester.pumpWidget(
        ActiveRouteControllerProvider.branch(
          route: expectedRoute,
          child: Builder(
            builder: (context) {
              try {
                ActiveRouteControllerProvider.controllerOf(context);
              } on Object catch (e) {
                caughtError = e;
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(caughtError, isA<ArgumentError>());
    });

    testWidgets(
        'nested branch under controller exposes both controller and branch '
        'route', (tester) async {
      // arrange
      final controller = _ControllerMock();
      ActiveRouteController? actualController;
      YxRoute? actualBranchRoute;

      // act
      await tester.pumpWidget(
        ActiveRouteControllerProvider(
          controller: controller,
          child: ActiveRouteControllerProvider.branch(
            route: expectedRoute,
            child: Builder(
              builder: (context) {
                actualController =
                    ActiveRouteControllerProvider.controllerMaybeOf(context);
                actualBranchRoute =
                    ActiveRouteControllerProvider.branchRouteMaybeOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // assert
      expect(actualController, same(controller));
      expect(actualBranchRoute, same(expectedRoute));
    });
  });
}
