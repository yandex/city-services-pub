import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yx_navigation_flutter/src/config/navigation_config_provider.dart';
import 'package:yx_navigation_flutter/src/config/navigation_defaults.dart';
import 'package:yx_navigation_flutter/src/page_factory/pages_factory.dart';

import '../helpers/fallbacks.dart';

void main() {
  setUpAll(registerFallbacks);

  group('NavigationDefaults', () {
    test('copyWith overrides only specified fields', () {
      // arrange
      const actualDefaults = NavigationDefaults();
      const expectedPageFactory = PagesFactory<Object?>.cupertino();

      // act
      final actualUpdated =
          actualDefaults.copyWith(pageFactory: expectedPageFactory);

      // assert
      expect(actualUpdated.pageFactory, same(expectedPageFactory));
      expect(
        actualUpdated.transitionDelegate,
        same(actualDefaults.transitionDelegate),
      );
      expect(
        actualUpdated.widgetBuilder,
        same(actualDefaults.widgetBuilder),
      );
    });

    testWidgets(
        'resolveNavigationDefaults falls back to defaults when no provider',
        (tester) async {
      // arrange
      NavigationDefaults? actualResolved;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            actualResolved =
                NavigationDefaults.resolveNavigationDefaults(context);
            return const SizedBox.shrink();
          },
        ),
      );

      // assert
      expect(actualResolved, isNotNull);
      expect(
        actualResolved!.transitionDelegate,
        same(NavigationDefaults.defaultsTransitionDelegate),
      );
    });

    testWidgets(
        'resolveNavigationDefaults reads defaults from provider when present',
        (tester) async {
      // arrange
      const expectedDefaults = NavigationDefaults(
        pageFactory: PagesFactory<Object?>.cupertino(),
      );
      NavigationDefaults? actualResolved;

      // act
      await tester.pumpWidget(
        NavigationConfigProvider(
          defaults: expectedDefaults,
          child: Builder(
            builder: (context) {
              actualResolved =
                  NavigationDefaults.resolveNavigationDefaults(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // assert
      expect(actualResolved, same(expectedDefaults));
    });
  });
}
